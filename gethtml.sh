#!/usr/bin/env bash
curl "http://neo.jpl.nasa.gov/cgi-bin/neo_ca?type=NEO&hmax=all&sort=date&sdir=ASC&tlim=far_future&dmax=0.2AU&max_rows=0&action=Display+Table&show=1" -o `pwd`/lowflyingrocks.html
