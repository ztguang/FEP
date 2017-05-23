/* -*- Mode:C++; c-file-style:"gnu"; indent-tabs-mode:nil; -*- */
/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation;
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

// Network topology
//
//    (android-1)    eth0   eth1
//                    n0     n2
//                    |      |
//                   ---   ----
//                   |S1|  |S2|
//                   ---   ----
//                    |      |
//                    n1     n3
//    (android-2)    eth0   eth1

// eth0 (android-1) <--> br_m_11 <--> tap_m_11 <--> switch1 (NS3) <--> tap_m_12 <--> br_m_12 <--> eth0 (android-2)

// eth1 (android-1) <--> br_m_21 <--> tap_m_21 <--> switch2 (NS3) <--> tap_m_22 <--> br_m_22 <--> eth1 (android-2)
//

#include <iostream>
#include <fstream>

#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/csma-module.h"
#include "ns3/openflow-module.h"
#include "ns3/tap-bridge-module.h"

#include "ns3/log.h"

using namespace ns3;

NS_LOG_COMPONENT_DEFINE ("OpenFlowCsmaSwitchWin7");

bool verbose = false;
bool use_drop = false;
ns3::Time timeout = ns3::Seconds (0);

bool
SetVerbose (std::string value)
{
  verbose = true;
  return true;
}

bool
SetDrop (std::string value)
{
  use_drop = true;
  return true;
}

bool
SetTimeout (std::string value)
{
  try {
      timeout = ns3::Seconds (atof (value.c_str ()));
      return true;
    }
  catch (...) { return false; }
  return false;
}

int
main (int argc, char *argv[])
{

  #ifdef NS3_OPENFLOW

  CommandLine cmd;
  cmd.AddValue ("v", "Verbose (turns on logging).", MakeCallback (&SetVerbose));
  cmd.AddValue ("verbose", "Verbose (turns on logging).", MakeCallback (&SetVerbose));
  cmd.AddValue ("d", "Use Drop Controller (Learning if not specified).", MakeCallback (&SetDrop));
  cmd.AddValue ("drop", "Use Drop Controller (Learning if not specified).", MakeCallback (&SetDrop));
  cmd.AddValue ("t", "Learning Controller Timeout (has no effect if drop controller is specified).", MakeCallback ( &SetTimeout));
  cmd.AddValue ("timeout", "Learning Controller Timeout (has no effect if drop controller is specified).", MakeCallback ( &SetTimeout));

  cmd.Parse (argc, argv);

  if (verbose)
    {
      LogComponentEnable ("OpenFlowCsmaSwitchExample", LOG_LEVEL_INFO);
      LogComponentEnable ("OpenFlowInterface", LOG_LEVEL_INFO);
      LogComponentEnable ("OpenFlowSwitchNetDevice", LOG_LEVEL_INFO);
    }

  //
  // Explicitly create the nodes required by the topology (shown above).
  //
  NS_LOG_INFO ("Create nodes.");
  NodeContainer nodes;
  nodes.Create (4);

  NodeContainer csmaSwitch;
  csmaSwitch.Create (2);

  NS_LOG_INFO ("Build Topology");
  CsmaHelper csma;
  csma.SetChannelAttribute ("DataRate", DataRateValue (5000000));
  csma.SetChannelAttribute ("Delay", TimeValue (MilliSeconds (2)));

  //-------------------------------------------------------------------------Switch1
  // Create the csma links, from each terminal to the switch
  NetDeviceContainer terminalDevices;
  NetDeviceContainer switchDevice1;

  for (int i = 0; i < 2; i++)
  {
      NetDeviceContainer link = csma.Install (NodeContainer (nodes.Get (i), csmaSwitch.Get (0)));
      terminalDevices.Add (link.Get (0));
      switchDevice1.Add (link.Get (1));
  }

  // Create the switch netdevice, which will do the packet switching
  Ptr<Node> switchNode1 = csmaSwitch.Get (0);
  OpenFlowSwitchHelper swtch1;

  if (use_drop)
  {
      Ptr<ns3::ofi::DropController> controller1 = CreateObject<ns3::ofi::DropController> ();
      swtch1.Install (switchNode1, switchDevice1, controller1);
  }
  else
  {
      Ptr<ns3::ofi::LearningController> controller1 = CreateObject<ns3::ofi::LearningController> ();
      if (!timeout.IsZero ()) controller1->SetAttribute ("ExpirationTime", TimeValue (timeout));
      swtch1.Install (switchNode1, switchDevice1, controller1);
  }
  //-------------------------------------------------------------------------Switch1


  //-------------------------------------------------------------------------Switch2
  //NetDeviceContainer terminalDevices;
  NetDeviceContainer switchDevice2;

  for (int i = 2; i < 4; i++)
  {
      NetDeviceContainer link = csma.Install (NodeContainer (nodes.Get (i), csmaSwitch.Get (1)));
      terminalDevices.Add (link.Get (0));
      switchDevice2.Add (link.Get (1));
  }

  // Create the switch netdevice, which will do the packet switching
  Ptr<Node> switchNode2 = csmaSwitch.Get (1);
  OpenFlowSwitchHelper swtch2;

  if (use_drop)
  {
      Ptr<ns3::ofi::DropController> controller2 = CreateObject<ns3::ofi::DropController> ();
      swtch2.Install (switchNode2, switchDevice2, controller2);
  }
  else
  {
      Ptr<ns3::ofi::LearningController> controller2 = CreateObject<ns3::ofi::LearningController> ();
      if (!timeout.IsZero ()) controller2->SetAttribute ("ExpirationTime", TimeValue (timeout));
      swtch2.Install (switchNode2, switchDevice2, controller2);
  }
  //-------------------------------------------------------------------------Switch2


  //
  // Configure tracing of all enqueue, dequeue, and NetDevice receive events.
  // Trace output will be sent to the file "openflow-switch.tr"
  //
  AsciiTraceHelper ascii;
  csma.EnableAsciiAll (ascii.CreateFileStream ("fep_mptcp_2_switches.tr"));

  //
  // Also configure some tcpdump traces; each interface will be traced.
  // The output files will be named:
  //     openflow-switch-<nodeId>-<interfaceId>.pcap
  // and can be read by the "tcpdump -r" command (use "-tt" option to
  // display timestamps correctly)
  //
  csma.EnablePcapAll ("fep_mptcp_2_switches", false);

  //
  // Use the TapBridgeHelper to connect to the pre-configured tap devices for 
  // the left side.  We go with "UseBridge" mode since the CSMA devices support
  // promiscuous mode and can therefore make it appear that the bridge is 
  // extended into ns-3.  The install method essentially bridges the specified
  // tap to the specified CSMA device.
  //
  TapBridgeHelper tapBridge;
  tapBridge.SetAttribute ("Mode", StringValue ("UseBridge"));

  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_m_11"));
  tapBridge.Install (nodes.Get (0), terminalDevices.Get (0));

  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_m_12"));
  tapBridge.Install (nodes.Get (1), terminalDevices.Get (1));

  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_m_21"));
  tapBridge.Install (nodes.Get (2), terminalDevices.Get (2));

  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_m_22"));
  tapBridge.Install (nodes.Get (3), terminalDevices.Get (3));


  //
  // Now, do the actual simulation.
  //
  NS_LOG_INFO ("Run Simulation.");
  Simulator::Run ();
  Simulator::Destroy ();
  NS_LOG_INFO ("Done.");
  #else
  NS_LOG_INFO ("NS-3 OpenFlow is not enabled. Cannot run simulation.");
  #endif // NS3_OPENFLOW
}
