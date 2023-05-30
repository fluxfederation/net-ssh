require_relative 'common'
require 'net/ssh'

class TestKeyExchange < NetSSHTest
  include IntegrationTestHelpers

  Net::SSH::Transport::Algorithms::DEFAULT_ALGORITHMS[:kex].each do |kex|
    define_method("test_kex_#{kex}") do
      skip "#{kex} not supported on newer sshd" if unsupported_kex_on_sshd_8?(kex) && sshd_8_or_later?

      ret = Net::SSH.start("localhost", "net_ssh_1", password: 'foopwd', kex: kex) do |ssh|
        ssh.exec! "echo 'foo'"
      end
      assert_equal "foo\n", ret
      assert_equal 0, ret.exitstatus
    end
  end

  private

  def unsupported_kex_on_sshd_8?(kex)
    %w[diffie-hellman-group14-sha1 diffie-hellman-group1-sha1 diffie-hellman-group-exchange-sha1].include?(kex)
  end
end
