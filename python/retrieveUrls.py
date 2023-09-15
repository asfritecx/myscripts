#!/usr/bin/python3

# Retrieves all href links from a webpage

import urllib3.request
from bs4 import BeautifulSoup
import re
import os
from urllib.parse import urlparse

url = 'https://example.com/path/path2'
http = urllib3.PoolManager()

# Spoof user agent
ua_header = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}

# Makes the request
resp = http.request(
    "GET",
    url,
    headers= ua_header
)

soup = BeautifulSoup(resp.data.decode('utf-8'), 'html.parser')

for link in soup.find_all('a'):
    print(link.get('href'))
