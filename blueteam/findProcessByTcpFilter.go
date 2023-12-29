// GOOS=windows GOARCH=386 go build -ldflags="-s -w" -o findProcessByTcpFilter.exe
package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/google/gopacket"
	"github.com/google/gopacket/layers"
	"github.com/google/gopacket/pcap"
	"github.com/shirou/gopsutil/net"
	"github.com/shirou/gopsutil/process"
	"github.com/sirupsen/logrus"
)

var (
	snapshotLen int32 = 1024
	promiscuous bool  = true
	device            = flag.String("d", "any", "网卡")
	filter            = flag.String("f", "dst 1.2.3.4", "BPF filter")
)

func main() {
	flag.Parse()

	findDevice()
	// Open device

	handle, err := pcap.OpenLive(*device, snapshotLen, promiscuous, pcap.BlockForever)
	if err != nil {
		log.Fatal(err)
	}
	defer handle.Close()

	// Set filter
	err = handle.SetBPFFilter(*filter)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Only capturing:", *filter)

	packetSource := gopacket.NewPacketSource(handle, handle.LinkType())
	for packet := range packetSource.Packets() {
		printPacketInfo(packet)
	}
}

func findDevice() {
	if *device == "any" {
		devices, err := pcap.FindAllDevs()
		if err != nil {
			logrus.Fatal(err)
		}
		logrus.Warnf("缺少网卡: 从下面选择一个网卡加入到启动参数中%s -d DEV", os.Args[0])
		for _, d := range devices {
			fmt.Println("DEV:", d.Name, "description:", d.Description)
		}

		os.Exit(-1)
	}
}

func printPacketInfo(packet gopacket.Packet) {
	// Let’s see if the packet is IP (even though the ether type told us)
	ipLayer := packet.Layer(layers.LayerTypeIPv4)
	if ipLayer != nil {
		ip, _ := ipLayer.(*layers.IPv4)

		tcpLayer := packet.Layer(layers.LayerTypeTCP)
		if tcpLayer != nil {
			tcp, _ := tcpLayer.(*layers.TCP)

			logrus.Printf("%s:%s = > %s:%s",
				ip.SrcIP, tcp.SrcPort, ip.DstIP, tcp.DstPort)

			find(ip.SrcIP.String(), ip.DstIP.String(),
				uint16(tcp.SrcPort), uint16(tcp.DstPort))

		}
	}

	if err := packet.ErrorLayer(); err != nil {
		fmt.Println("Error decoding some part of the packet:", err)
	}
}

func find(l, r string, lp, rp uint16) {
	connections, err := net.Connections("all")
	if err != nil {
		logrus.Error("net.Connections:", err.Error())
		os.Exit(-1)
	}
	for _, conn := range connections {

		if conn.Laddr.IP == l &&
			conn.Raddr.IP == r &&
			uint16(conn.Laddr.Port) == lp &&
			uint16(conn.Raddr.Port) == rp {

			logrus.Warn("processId:", conn.Pid)

			ps, err := process.Processes()
			if err != nil {
				logrus.Error("process.Processes:", err.Error())
				os.Exit(-1)
			}
			for _, proc := range ps {
				if proc.Pid == conn.Pid {
					parentPid, _ := proc.Ppid()
					user, _ := proc.Username()
					name, _ := proc.Name()
					createTime, _ := proc.CreateTime()
					startTime := time.Unix(createTime/1000, 0).Format("2006-01-02 15:04:05")
					cmd, _ := proc.Cmdline()
					path, _ := proc.Cwd()

					logrus.Warnf(`ProcessInformation:
						Name: %s
						ParentPid: %d
						startTime: %s
						user: %s
						cmd:%s
						path:%s
						`, name, parentPid, startTime, user, cmd, path)
					return
				}
			}
		}
	}
}
