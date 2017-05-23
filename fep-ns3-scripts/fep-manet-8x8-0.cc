/* -*-  Mode: C++; c-file-style: "gnu"; indent-tabs-mode:nil; -*- */
/*
 * Copyright (c) 2009 University of Washington
 *
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
 *
 */

#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/mobility-module.h"
#include "ns3/config-store-module.h"
#include "ns3/wifi-module.h"

#include "ns3/tap-bridge-module.h"

#include <iostream>
#include <fstream>
#include <vector>
#include <string>

using namespace ns3;

NS_LOG_COMPONENT_DEFINE ("WifiSimpleAdhocGrid");

void ReceivePacket (Ptr<Socket> socket)
{
  while (socket->Recv ())
    {
      NS_LOG_UNCOND ("Received one packet!");
    }
}

static void GenerateTraffic (Ptr<Socket> socket, uint32_t pktSize, 
                             uint32_t pktCount, Time pktInterval )
{
  if (pktCount > 0)
    {
      socket->Send (Create<Packet> (pktSize));
      Simulator::Schedule (pktInterval, &GenerateTraffic, 
                           socket, pktSize,pktCount-1, pktInterval);
    }
  else
    {
      socket->Close ();
    }
}


int main (int argc, char *argv[])
{
  std::string phyMode ("DsssRate1Mbps");
  double distance = 500;  // m
  uint32_t packetSize = 1000; // bytes
  uint32_t numPackets = 1;
  uint32_t numNodes = 64;  // by default, 6x6
  uint32_t sinkNode = 0;
  uint32_t sourceNode = 63;
  bool verbose = false;
  bool tracing = false;

  int nodeSpeed = 1; //in m/s
  int nodePause = 0; //in s

  CommandLine cmd;

  cmd.AddValue ("phyMode", "Wifi Phy mode", phyMode);
  cmd.AddValue ("distance", "distance (m)", distance);
  cmd.AddValue ("packetSize", "size of application packet sent", packetSize);
  cmd.AddValue ("numPackets", "number of packets generated", numPackets);
  cmd.AddValue ("verbose", "turn on all WifiNetDevice log components", verbose);
  cmd.AddValue ("tracing", "turn on ascii and pcap tracing", tracing);
  cmd.AddValue ("numNodes", "number of nodes", numNodes);
  cmd.AddValue ("sinkNode", "Receiver node number", sinkNode);
  cmd.AddValue ("sourceNode", "Sender node number", sourceNode);

  cmd.Parse (argc, argv);

  // disable fragmentation for frames below 2200 bytes
  Config::SetDefault ("ns3::WifiRemoteStationManager::FragmentationThreshold", StringValue ("2200"));
  // turn off RTS/CTS for frames below 2200 bytes
  Config::SetDefault ("ns3::WifiRemoteStationManager::RtsCtsThreshold", StringValue ("2200"));
  // Fix non-unicast data rate to be the same as that of unicast
  Config::SetDefault ("ns3::WifiRemoteStationManager::NonUnicastMode", 
                      StringValue (phyMode));

  NodeContainer adhocNodes;
  adhocNodes.Create (numNodes);

  // The below set of helpers will help us to put together the wifi NICs we want
  WifiHelper wifi;
  if (verbose)
    {
      wifi.EnableLogComponents ();  // Turn on all Wifi logging
    }

  YansWifiPhyHelper wifiPhy =  YansWifiPhyHelper::Default ();
  // set it to zero; otherwise, gain will be added
  wifiPhy.Set ("RxGain", DoubleValue (-10) ); 
  // ns-3 supports RadioTap and Prism tracing extensions for 802.11b
  wifiPhy.SetPcapDataLinkType (YansWifiPhyHelper::DLT_IEEE802_11_RADIO); 

  YansWifiChannelHelper wifiChannel;
  wifiChannel.SetPropagationDelay ("ns3::ConstantSpeedPropagationDelayModel");
  wifiChannel.AddPropagationLoss ("ns3::FriisPropagationLossModel");
  wifiPhy.SetChannel (wifiChannel.Create ());

  // Add an upper mac and disable rate control
  WifiMacHelper wifiMac;
  wifi.SetStandard (WIFI_PHY_STANDARD_80211b);
  wifi.SetRemoteStationManager ("ns3::ConstantRateWifiManager",
                                "DataMode",StringValue (phyMode),
                                "ControlMode",StringValue (phyMode));
  // Set it to adhoc mode
  wifiMac.SetType ("ns3::AdhocWifiMac");
  NetDeviceContainer adhocDevices = wifi.Install (wifiPhy, wifiMac, adhocNodes);

//----------------------------------------------------------------------
  MobilityHelper mobilityAdhoc;
  int64_t streamIndex = 0; // used to get consistent mobility across scenarios

  ObjectFactory pos;
  pos.SetTypeId ("ns3::RandomRectanglePositionAllocator");
  pos.Set ("X", StringValue ("ns3::UniformRandomVariable[Min=0.0|Max=300.0]"));
  pos.Set ("Y", StringValue ("ns3::UniformRandomVariable[Min=0.0|Max=1500.0]"));

  Ptr<PositionAllocator> taPositionAlloc = pos.Create ()->GetObject<PositionAllocator> ();
  streamIndex += taPositionAlloc->AssignStreams (streamIndex);

  std::stringstream ssSpeed;
  ssSpeed << "ns3::UniformRandomVariable[Min=0.0|Max=" << nodeSpeed << "]";
  std::stringstream ssPause;
  ssPause << "ns3::ConstantRandomVariable[Constant=" << nodePause << "]";
  mobilityAdhoc.SetMobilityModel ("ns3::RandomWaypointMobilityModel",
                                  "Speed", StringValue (ssSpeed.str ()),
                                  "Pause", StringValue (ssPause.str ()),
                                  "PositionAllocator", PointerValue (taPositionAlloc));
  mobilityAdhoc.SetPositionAllocator ("ns3::GridPositionAllocator",
                                 "MinX", DoubleValue (-2000.0),
                                 "MinY", DoubleValue (-2000.0),
                                 "DeltaX", DoubleValue (distance),
                                 "DeltaY", DoubleValue (distance),
                                 "GridWidth", UintegerValue (8),
                                 "LayoutType", StringValue ("RowFirst"));

  mobilityAdhoc.Install (adhocNodes);
  streamIndex += mobilityAdhoc.AssignStreams (adhocNodes, streamIndex);
//----------------------------------------------------------------------

  //----------------------------------------------------------------------------------------------------
  // Use the TapBridgeHelper to connect to the pre-configured tap devices for 
  // the left side.  We go with "UseBridge" mode since the CSMA devices support
  // promiscuous mode and can therefore make it appear that the bridge is 
  // extended into ns-3.  The install method essentially bridges the specified
  // tap to the specified CSMA device.
  //
  TapBridgeHelper tapBridge;
  tapBridge.SetAttribute ("Mode", StringValue ("UseLocal"));

  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_1"));
  tapBridge.Install (adhocNodes.Get (0), adhocDevices.Get (0));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_2"));
  tapBridge.Install (adhocNodes.Get (1), adhocDevices.Get (1));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_3"));
  tapBridge.Install (adhocNodes.Get (2), adhocDevices.Get (2));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_4"));
  tapBridge.Install (adhocNodes.Get (3), adhocDevices.Get (3));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_5"));
  tapBridge.Install (adhocNodes.Get (4), adhocDevices.Get (4));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_6"));
  tapBridge.Install (adhocNodes.Get (5), adhocDevices.Get (5));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_7"));
  tapBridge.Install (adhocNodes.Get (6), adhocDevices.Get (6));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_8"));
  tapBridge.Install (adhocNodes.Get (7), adhocDevices.Get (7));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_9"));
  tapBridge.Install (adhocNodes.Get (8), adhocDevices.Get (8));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_10"));
  tapBridge.Install (adhocNodes.Get (9), adhocDevices.Get (9));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_11"));
  tapBridge.Install (adhocNodes.Get (10), adhocDevices.Get (10));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_12"));
  tapBridge.Install (adhocNodes.Get (11), adhocDevices.Get (11));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_13"));
  tapBridge.Install (adhocNodes.Get (12), adhocDevices.Get (12));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_14"));
  tapBridge.Install (adhocNodes.Get (13), adhocDevices.Get (13));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_15"));
  tapBridge.Install (adhocNodes.Get (14), adhocDevices.Get (14));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_16"));
  tapBridge.Install (adhocNodes.Get (15), adhocDevices.Get (15));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_17"));
  tapBridge.Install (adhocNodes.Get (16), adhocDevices.Get (16));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_18"));
  tapBridge.Install (adhocNodes.Get (17), adhocDevices.Get (17));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_19"));
  tapBridge.Install (adhocNodes.Get (18), adhocDevices.Get (18));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_20"));
  tapBridge.Install (adhocNodes.Get (19), adhocDevices.Get (19));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_21"));
  tapBridge.Install (adhocNodes.Get (20), adhocDevices.Get (20));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_22"));
  tapBridge.Install (adhocNodes.Get (21), adhocDevices.Get (21));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_23"));
  tapBridge.Install (adhocNodes.Get (22), adhocDevices.Get (22));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_24"));
  tapBridge.Install (adhocNodes.Get (23), adhocDevices.Get (23));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_25"));
  tapBridge.Install (adhocNodes.Get (24), adhocDevices.Get (24));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_26"));
  tapBridge.Install (adhocNodes.Get (25), adhocDevices.Get (25));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_27"));
  tapBridge.Install (adhocNodes.Get (26), adhocDevices.Get (26));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_28"));
  tapBridge.Install (adhocNodes.Get (27), adhocDevices.Get (27));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_29"));
  tapBridge.Install (adhocNodes.Get (28), adhocDevices.Get (28));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_30"));
  tapBridge.Install (adhocNodes.Get (29), adhocDevices.Get (29));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_31"));
  tapBridge.Install (adhocNodes.Get (30), adhocDevices.Get (30));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_32"));
  tapBridge.Install (adhocNodes.Get (31), adhocDevices.Get (31));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_33"));
  tapBridge.Install (adhocNodes.Get (32), adhocDevices.Get (32));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_34"));
  tapBridge.Install (adhocNodes.Get (33), adhocDevices.Get (33));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_35"));
  tapBridge.Install (adhocNodes.Get (34), adhocDevices.Get (34));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_36"));
  tapBridge.Install (adhocNodes.Get (35), adhocDevices.Get (35));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_37"));
  tapBridge.Install (adhocNodes.Get (36), adhocDevices.Get (36));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_38"));
  tapBridge.Install (adhocNodes.Get (37), adhocDevices.Get (37));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_39"));
  tapBridge.Install (adhocNodes.Get (38), adhocDevices.Get (38));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_40"));
  tapBridge.Install (adhocNodes.Get (39), adhocDevices.Get (39));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_41"));
  tapBridge.Install (adhocNodes.Get (40), adhocDevices.Get (40));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_42"));
  tapBridge.Install (adhocNodes.Get (41), adhocDevices.Get (41));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_43"));
  tapBridge.Install (adhocNodes.Get (42), adhocDevices.Get (42));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_44"));
  tapBridge.Install (adhocNodes.Get (43), adhocDevices.Get (43));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_45"));
  tapBridge.Install (adhocNodes.Get (44), adhocDevices.Get (44));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_46"));
  tapBridge.Install (adhocNodes.Get (45), adhocDevices.Get (45));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_47"));
  tapBridge.Install (adhocNodes.Get (46), adhocDevices.Get (46));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_48"));
  tapBridge.Install (adhocNodes.Get (47), adhocDevices.Get (47));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_49"));
  tapBridge.Install (adhocNodes.Get (48), adhocDevices.Get (48));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_50"));
  tapBridge.Install (adhocNodes.Get (49), adhocDevices.Get (49));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_51"));
  tapBridge.Install (adhocNodes.Get (50), adhocDevices.Get (50));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_52"));
  tapBridge.Install (adhocNodes.Get (51), adhocDevices.Get (51));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_53"));
  tapBridge.Install (adhocNodes.Get (52), adhocDevices.Get (52));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_54"));
  tapBridge.Install (adhocNodes.Get (53), adhocDevices.Get (53));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_55"));
  tapBridge.Install (adhocNodes.Get (54), adhocDevices.Get (54));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_56"));
  tapBridge.Install (adhocNodes.Get (55), adhocDevices.Get (55));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_57"));
  tapBridge.Install (adhocNodes.Get (56), adhocDevices.Get (56));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_58"));
  tapBridge.Install (adhocNodes.Get (57), adhocDevices.Get (57));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_59"));
  tapBridge.Install (adhocNodes.Get (58), adhocDevices.Get (58));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_60"));
  tapBridge.Install (adhocNodes.Get (59), adhocDevices.Get (59));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_61"));
  tapBridge.Install (adhocNodes.Get (60), adhocDevices.Get (60));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_62"));
  tapBridge.Install (adhocNodes.Get (61), adhocDevices.Get (61));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_63"));
  tapBridge.Install (adhocNodes.Get (62), adhocDevices.Get (62));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_64"));
  tapBridge.Install (adhocNodes.Get (63), adhocDevices.Get (63));
  
  Simulator::Run ();
  Simulator::Destroy ();

  return 0;
}
