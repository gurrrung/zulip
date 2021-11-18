class zulip::camo {
  package { 'camo':
    ensure => 'purged',
  }

  $version = '2.3.0'

  $dir = "/srv/zulip-go-camo-${version}/"
  $bin = "${dir}bin/go-camo"

  zulip::sha256_tarball_to { 'go-camo':
    url     => "https://github.com/cactus/go-camo/releases/download/v${version}/go-camo-${version}.go1171.linux-amd64.tar.gz",
    sha256  => '965506e6edb9d974c810519d71e847afb7ca69d1d01ae7d8be6d7a91de669c0c',
    install => {
      "go-camo-${version}/" => $dir,
    },
  }
  file { $dir:
    ensure  => directory,
    require => Zulip::Sha256_tarball_to['go-camo'],
  }
  tidy { '/srv/zulip-go-camo-*':
    path    => '/srv/',
    recurse => 1,
    rmdirs  => true,
    matches => 'zulip-go-camo-*',
    require => File[$dir],
  }

  $camo_key = zulipsecret('secrets', 'camo_key', '')
  file { "${zulip::common::supervisor_conf_dir}/go-camo.conf":
    ensure  => file,
    require => [
      Package[supervisor],
      File[$dir],
    ],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('zulip/supervisor/go-camo.conf.erb'),
    notify  => Service[supervisor],
  }
}
