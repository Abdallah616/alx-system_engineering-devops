# Install Nginx package
package { 'nginx':
  ensure => present,
}

# Define Nginx service
service { 'nginx':
  ensure    => running,
  enable    => true,
  hasrestart => true,
  hasstatus  => true,
  require   => Package['nginx'],
}

# Configure Nginx site
file { '/etc/nginx/sites-available/default':
  ensure  => file,
  content => "
server {
    listen 80;

    root /var/www/html;
    index index.html index.htm;

    location / {
        # Return Hello World! for root path
        return 200 'Hello World!';
    }

    location /redirect_me {
        # Perform a 301 redirect for /redirect_me
        return 301 http://\$host/;
    }

    error_page 404 /404.html;
    location = /404.html {
        root /usr/share/nginx/html;
        internal;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
  ",
  require => Package['nginx'],
  notify  => Service['nginx'],
}

# Create document root
file { '/var/www/html':
  ensure => directory,
}

# Reload Nginx when the configuration changes
exec { 'nginx-reload':
  command     => 'service nginx reload',
  refreshonly => true,
  subscribe   => File['/etc/nginx/sites-available/default'],
}
