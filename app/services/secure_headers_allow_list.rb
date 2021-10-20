class SecureHeadersAllowList
  def self.extract_domain(url)
    url.split('//')[1].split('/')[0]
  end

  def self.csp_with_sp_redirect_uris(action_url_domain, sp_redirect_uris)
    csp_uris = ["'self'", action_url_domain]

    sp_redirect_hosts = Array(sp_redirect_uris).map do |redirect_uri|
      uri = URI.parse(redirect_uri)
      "#{uri.scheme}://#{uri.host}:#{uri.port}"
    end.compact.uniq

    csp_uris |= sp_redirect_hosts if sp_redirect_hosts.present?

    csp_uris
  end
end
