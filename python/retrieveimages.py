#!/usr/bin/python3

# Simple jpg/jpeg image downloader
# Usage : retrieveimages.py enternamehere https://example.com
# A downloaded_image folder will be created in the same path as this script


import sys,time,random,re,os
import urllib3.request
from bs4 import BeautifulSoup
from urllib.parse import urlparse
from PIL import Image


# Check if the URL argument is provided
if len(sys.argv) != 3:
    print("Usage: python retrieveimages.py enternamehere https://example.com")
    sys.exit(1)

# Get the URL from the command-line argument
chapter_name = sys.argv[1]
url = sys.argv[2]

# Generate a random delay between 1 and 5 minutes (in seconds)
random_delay = random.randint(20, 300)

# Countdown loop to refresh output in terminal
for remaining in range(random_delay, -1, -1):
    sys.stdout.write(f"\rWaiting for {remaining} seconds...  ")
    sys.stdout.flush()
    time.sleep(1)

sys.stdout.write("\r" + " " * 50 + "\n")  # Clear the line

http = urllib3.PoolManager()
# Create a directory to store the chapter images
chapter_directory = os.path.join('downloaded_images', chapter_name)
os.makedirs(chapter_directory, exist_ok=True)
ua_header = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.107 Safari/537.36'}

try:
    # Makes the request
    resp = http.request(
        "GET",
        url,
        headers= ua_header
    )

    soup = BeautifulSoup(resp.data.decode('utf-8'), 'html.parser')
    parsed = soup.body.find_all('img')
    image_links = [re.search(r'data-src="([^"]+)"', str(tag)).group(1) for tag in parsed if re.search(r'data-src="([^"]+)"', str(tag))]

    # Print the image links
    # For troubleshooting
    for link in image_links:
         print(link)

    for idx, tag in enumerate(parsed):
        link_match = re.search(r'data-src="([^"]+)"', str(tag))
        if link_match:
            image_link = link_match.group(1)
            image_name = os.path.basename(urlparse(image_link).path)
            file_path = os.path.join(chapter_directory, image_name)

            # Download the image and save it as a file
            with http.request('GET', image_link, preload_content=False) as response, open(file_path, 'wb') as out_file:
                out_file.write(response.data)

            if file_path.lower().endswith('.webp'):
                webp_image = Image.open(file_path)
                webp_image = webp_image.convert('RGB')
                jpeg_path = os.path.splitext(file_path)[0] + '.jpg'
                webp_image.save(jpeg_path, format='JPEG')
                os.remove(file_path)  # Remove the original WebP file

    print("Images downloaded and saved with appropriate filenames.")

except urllib3.exceptions.HTTPError as e:
    print(f"Error fetching URL: {e}")
except Exception as e:
    print(f"An error occurred: {e}")
