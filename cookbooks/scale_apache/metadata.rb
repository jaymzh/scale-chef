name             'scale_apache'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures scale_apache'
source_url 'https://github.com/socallinuxexpo/scale-chef'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'
depends 'fb_apache'
depends 'scale_drupal'
