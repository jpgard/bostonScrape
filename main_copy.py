#!/usr/bin/env python
# -*- coding: utf-8 -*-
import csv
import errno
import itertools
import os
import time

from bs4 import BeautifulSoup
import click
import dataset
import funcy as fy
import requests


HTML_DB_FILENAME = 'scraped_html_main_2.db'

DATASET = dataset.connect('sqlite:///' + HTML_DB_FILENAME)
TABLE = DATASET['raw_html']


def mkdir_p(path):
    """
    Makes directories. Taken from: http://stackoverflow.com/a/600612
    """
    try:
        os.makedirs(path)
    except OSError as exc: # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else:
            raise


@click.group()
def cli():
    """Pile of commands to scrape the boston marathon results."""
    pass


def extract_entrants(html):
    """Generator yielding entrant info dicts given an HTML file."""
    soup = BeautifulSoup(html, 'lxml')
    trs = soup.select('.tablegrid_list_item > .tablegrid_table > tbody > tr')

    # Two rows per entrant, so we group them in pairs, omitting the extra end
    # row.
    user_rows = fy.ipartition(2, trs)

    for tr_header, tr_data in user_rows:
        header_strings = [td.get_text(strip=True)
                          for td in tr_header.find_all('td', recursive=False)]
        assert len(header_strings) == 9
        #TODO: change to correct length?
        
        data_strings = [td.get_text(strip=True) for td in tr_data.select('td')[0].select('td')]
        assert len(data_strings) == 15
        
        # look at tr_header and tr_data here using ipdb;
        #import ipdb; ipdb.set_trace()

        yield {
            'bib_number': header_strings[0],
            'name': header_strings[1],
            'age': header_strings[2],
            'gender': header_strings[3],
            'city': header_strings[4],
            'state': header_strings[5],
            'county': header_strings[6],
            'origin': header_strings[7],
            #new items added by JG
            '5k': data_strings[0],
            '10k': data_strings[1],
            '15k': data_strings[2],
            '20k': data_strings[3],
            'half': data_strings[4],
            '25k': data_strings[5],
            '30k': data_strings[6],
            '35k': data_strings[7],
            '40k': data_strings[8],
            'pace' : data_strings[9],
            'projected_time' : data_strings[10],
            'official_time' : data_strings[11],
            'overall_place' : data_strings[12],
            'gender_place' : data_strings[13],
            'division_place' : data_strings[14]
        }


@cli.command()
@click.argument('output_csv', type=click.File('wb'))
def output_csv(output_csv):
    """Write a csv listing of all entrants."""
    entrants = fy.cat(extract_entrants(row['page_html']) for row in TABLE.all())

    # We could technically use the first entry's keys, but I like this column order.
    keys = [
        'bib_number',
        'name',
        'age',
        'gender',
        'city',
        'state',
        'county',
        'origin',
        #new items added by JG
        '5k',
        '10k',
        '15k',
        '20k',
        'half',
        '25k',
        '30k',
        '35k',
        '40k',
        'pace',
        'projected_time',
        'official_time',
        'overall_place',
        'gender_place',
        'division_place'
    ]
    writer = csv.DictWriter(output_csv, keys)
    writer.writeheader()
    writer.writerows(entrants)

    click.echo('Wrote %d entrants.' % len(entrants))


@cli.command()
def output_html():
    """Write all pages in the database into HTML files."""
    mkdir_p('output')
    for row in TABLE.all():
        filename = 'output/state_%s_page_%s.html' % (row['state_id'], row['page_number'])
        click.echo('Writing ' + filename)
        with file(filename, 'w') as f:
            f.write(row['page_html'])


def scrape_state(state_id):
    """
    Generator yielding pages of HTML for a particular state.

    Returns tuples of (page_number, html_text).
    """
    # Fuckton of random shit in here, but whatever, don't fuck with whatever the
    # server is doing if it works.
    headers = {
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Encoding': 'gzip, deflate',
        'Accept-Language': 'en-US,en;q=0.8',
        'Cache-Control': 'max-age=0',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Origin': 'http://registration.baa.org',
        'Referer': 'http://registration.baa.org/2015/cf/Public/iframe_ResultsSearch.cfm?mode=results',
    }
    params = {
        'mode': 'results',
        'criteria': '',
        'StoredProcParamsOn': 'yes',
        'VarGenderID': 0,
        'VarBibNumber': '',
        'VarLastName': '',
        'VarFirstName': '',
        'VarStateID': state_id,
        'VarCountryOfResID': 0,
        'VarCountryOfCtzID': 0,
        'VarReportingSegID': 1,
        'VarAwardsDivID': 0,
        'VarQualClassID': 0,
        'VarCity': '',
        'VarTargetCount': 1000,
        'records': 25,
        'headerexists': 'Yes',
        'bordersize': 0,
        'bordercolor': '#ffffff',
        'rowcolorone': '#FFCC33',
        'rowcolortwo': '#FFCC33',
        'headercolor': '#ffffff',
        'headerfontface': 'Verdana,Arial,Helvetica,sans-serif',
        'headerfontcolor': '#004080',
        'headerfontsize': '12px',
        'fontface': 'Verdana,Arial,Helvetica,sans-serif',
        'fontcolor': '#000099',
        'fontsize': '10px',
        'linkfield': 'FormattedSortName',
        'linkurl': 'OpenDetailsWindow',
        'linkparams': 'RaceAppID',
        'queryname': 'SearchResults',
        'tablefields': 'FullBibNumber,FormattedSortName,AgeOnRaceDay,GenderCode,'
                       'City,StateAbbrev,CountryOfResAbbrev,CountryOfCtzAbbrev,'
                       'DisabilityGroup',
    }

    for page_number, start in enumerate(itertools.count(1, 25)):
        # Don't hammer the server. Give it a sec between requests.
        time.sleep(1.0)

        click.echo('Requesting state %d - page %d' % (state_id, page_number))
        response = requests.post(
            'http://registration.baa.org/2015/cf/Public/iframe_ResultsSearch.cfm',
            headers=headers,
            params=params,
            data={'start': start, 'next': 'Next 25 Records'},
        )
        response.raise_for_status()

        # Only yield if there actually are results. Just found this random
        # tr_header thing in the HTML of the pages that have results, but not
        # empty results pages.
        if 'tr_header' in response.text:
            yield page_number, response.text
        else:
            assert 'Next 25 Records' not in response.text
            click.echo('  No results found.')
            break

        # No more pages!
        if 'Next 25 Records' not in response.text:
            break


@cli.command()
def scrape():
    """Pull down HTML from the server into dataset."""
    # Bullshit, I know right? But no, go look at the search page.
    state_ids = range(2, 78)

    for state_id in state_ids:
        for page_number, page_html in scrape_state(state_id):
            TABLE.upsert(dict(
                state_id=1,
                page_number=page_number,
                page_html=page_html,
            ), ['state_id', 'page_number'])


if __name__ == '__main__':
    cli()
