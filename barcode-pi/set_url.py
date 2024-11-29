from PyQt5.QtCore import QSettings

def set_feed_url(url):
    settings = QSettings('1', '1')
    settings.setValue('url', url)
    print(f"Feed URL has been set to: {url}")

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python3 set_url.py <feed_url>")
        sys.exit(1)
    set_feed_url(sys.argv[1]) 