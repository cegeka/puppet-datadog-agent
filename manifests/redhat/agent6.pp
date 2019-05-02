# Class: datadog_agent::redhat::agent6
#
# This class contains the DataDog agent installation mechanism for Red Hat derivatives
#

class datadog_agent::redhat::agent6(
  $baseurl = "https://yum.datadoghq.com/beta/${::architecture}/",
  $gpgkey = 'https://yum.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public',
  $manage_repo = true,
  $agent_version = 'latest'
) inherits datadog_agent::params {

  validate_bool($manage_repo)
  if $manage_repo {
    $public_key_local = '/etc/pki/rpm-gpg/DATADOG_RPM_KEY.public'

    validate_string($baseurl)

    yumrepo {'datadog':
      enabled  => 1,
      gpgcheck => 1,
      gpgkey   => 'https://yum.datadoghq.com/DATADOG_RPM_KEY.public https://yum.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public',
      descr    => 'Datadog, Inc.',
      baseurl  => $baseurl
    }

    Package { require => Yumrepo['datadog']}
  }

  package { 'datadog-agent-base':
    ensure => absent,
    before => Package[$datadog_agent::params::package_name],
  }

  package { $datadog_agent::params::package_name:
    ensure  => $agent_version,
  }

  service { $datadog_agent::params::service_name:
    ensure    => $::datadog_agent::service_ensure,
    enable    => $::datadog_agent::service_enable,
    hasstatus => false,
    pattern   => 'dd-agent',
    provider  => 'redhat',
    require   => Package[$datadog_agent::params::package_name],
  }

}
