# Copyright 2013, Dell 
# 
# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 
# 
#  http://www.apache.org/licenses/LICENSE-2.0 
# 
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License. 

require 'test_helper'
 
class AttribIpAddressTest < ActiveSupport::TestCase

  # Test retrieval of ip address for default network
  test "Ip address retrieval: default network success" do
    barclamp = NetworkTestHelper.create_a_barclamp()
    deployment = barclamp.create_or_get_deployment()

    node = Node.new(:name => "fred.flintstone.org")
    node.save!

    allocated_ip = allocate_ip(deployment, NetworkTestHelper::DEFAULT_NETWORK_NAME, node)

    ip_address = node.get_attrib("ip_address")
    assert_equal allocated_ip, ip_address.actual(NetworkTestHelper::DEFAULT_NETWORK_NAME, deployment.id, BarclampNetwork::NetworkUtils::PROPOSED_SNAPSHOT)
  end


  # Test retrieval of ip address for specified network
  test "Ip address retrieval: specified network success" do
    barclamp = NetworkTestHelper.create_a_barclamp()
    deployment = barclamp.create_or_get_deployment()

    node = Node.new(:name => "fred7.flintstone.org")
    node.save!

    net1_allocated_ip = allocate_ip(deployment, "#{NetworkTestHelper::DEFAULT_NETWORK_NAME}_1", node)
    net2_allocated_ip = allocate_ip(deployment, "#{NetworkTestHelper::DEFAULT_NETWORK_NAME}_2", node)

    ip_address = node.get_attrib("ip_address")
    assert_equal net1_allocated_ip, ip_address.actual("#{NetworkTestHelper::DEFAULT_NETWORK_NAME}_1", deployment.id, BarclampNetwork::NetworkUtils::PROPOSED_SNAPSHOT)
    assert_equal net2_allocated_ip, ip_address.actual("#{NetworkTestHelper::DEFAULT_NETWORK_NAME}_2", deployment.id, BarclampNetwork::NetworkUtils::PROPOSED_SNAPSHOT)
  end


  private

  def allocate_ip(deployment, network_name, node)
    network = NetworkTestHelper.create_a_network(deployment, network_name)
    network.save!

    http_error, message = network.allocate_ip("host", node)
    assert_equal 200, http_error
    message["address"]
  end
end
