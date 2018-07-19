require 'webmock'
include WebMock::API

WebMock.enable!

stub_request(:any, "https://api.github.com/orgs/bostonhacks/members")