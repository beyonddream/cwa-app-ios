////
// 🦠 Corona-Warn-App
//

import Foundation

#if DEBUG
enum HealthCertificateMocks {

	// swiftlint:disable line_length
	static let mockBase45: String = "HC1:6BFOXN*TS0BI$ZD4N9:9S6RCVN5+O30K3/XIV0W23NTDEXWK G2EP4J0BGJLFX3R3VHXK.PJ:2DPF6R:5SVBHABVCNN95SWMPHQUHQN%A0SOE+QQAB-HQ/HQ7IR.SQEEOK9SAI4- 7Y15KBPD34  QWSP0WRGTQFNPLIR.KQNA7N95U/3FJCTG90OARH9P1J4HGZJKBEG%123ZC$0BCI757TLXKIBTV5TN%2LXK-$CH4TSXKZ4S/$K%0KPQ1HEP9.PZE9Q$95:UENEUW6646936HRTO$9KZ56DE/.QC$Q3J62:6LZ6O59++9-G9+E93ZM$96TV6NRN3T59YLQM1VRMP$I/XK$M8PK66YBTJ1ZO8B-S-*O5W41FD$ 81JP%KNEV45G1H*KESHMN2/TU3UQQKE*QHXSMNV25$1PK50C9B/9OK5NE1 9V2:U6A1ELUCT16DEETUM/UIN9P8Q:KPFY1W+UN MUNU8T1PEEG%5TW5A 6YO67N6BBEWED/3LS3N6YU.:KJWKPZ9+CQP2IOMH.PR97QC:ACZAH.SYEDK3EL-FIK9J8JRBC7ADHWQYSK48UNZGG NAVEHWEOSUI2L.9OR8FHB0T5HM7I"

	static let firstBase45Mock: String = "HC1:NCFOXN%TS3DH3ZSUZK+.V0ETD%65NL-AH1YIIOOP-IEDCQN68WA+J7U:CAT4V22F/8X*G3M9JUPY0BX/KR96R/S09T./0LWTKD33238J3HKB5S4VV2 73-E3GG396B-43O058YIZ73423ZQT*EJMD3EV40ATOLN0$4*2D523U53/GNNM0323:QT4XATOB273I97EG3MHF3%8YC3YGFSZV9/0F.8HLVDEFV+0B/S7-SN2H N37J3JFT6LJS$98T5V7AMI5DN9QZ5Y0Q$UPE%5MZ5*T57ZA$O7T6LEJOA+MZ55EIIPEBFVA.QO5VA81K0ECM8CCR1SOOEA7IB6$C94JBPC9AFMO6HNVL6SH.6A4JBY.C4KE5.B--C$JDBLEH-BWOJ96K0DI1PC6LFDNJI-B7DA2KCUDBQEAJJKHHGEC8ZI9$JAQJKLFHDFROZ25%1NXPTG90Q480G:NE--ETAOR7G31BU187$BUPO8 FYL7AEFI+U/2VD3DXQB/OTC1IST0XIJRSE7+56NU%JS8FF%NKG30/A2PYK$ZE550GOV*0"
	
	static let lastBase45Mock: String = "HC1:NCFOXN%TS3DH3ZSUZK+.V0ETD%65NL-AH1YIIOOP-IHECIW18WA$H7EH3AT4V22F/8X*G3M9JUPY0BX/KQ96R/S09T./0LWTKD33238J3HKB5S4VV2 73-E3GG396B-43O058YIZ73423ZQT*EJEG3SP40ATOLN0$4*2D523U53/GNNM0323:QT4XA9Q7UW8X*8* 0$SFIBBLOJ.YV$23KBBHKNSN7+F7V+0B/S7-SN2H N37J3JFT6LJS$98T5V7AMI5DN9QZ5Y0Q$UPE%5MZ5*T57ZA$O7T6LEJOA+MZ55EIIPEBFVA.QO5VA81K0ECM8CCR1SOOEA7IB6$C94JBPC9AFMO6HNVL6SH.6A4JBY.C4KE5.B--C$JDBLEH-BWOJ96K0DI1PC6LFDNJI-B7DA2KCUDBQEAJJKHHGEC8ZI9$JAQJKLFHCEP .G1729XNSP986I-:FTCBIXT3ZTM*D35KYL0:/A2+JYEM$LBHM4*EMSANKAB9U672S HO3OV:5WKA1*07B%F7-V$R4D37K9MYAALFD*V41W7-C86DG"

}

extension HealthCertificate {

	static func mock(
		base45: String = HealthCertificateMocks.mockBase45,
		validityState: HealthCertificateValidityState = .valid,
		isNew: Bool = false,
		isValidityStateNew: Bool = false
	) -> HealthCertificate {
		do {
			return try HealthCertificate(
				base45: base45,
				validityState: validityState,
				isNew: isNew,
				isValidityStateNew: isValidityStateNew
			)
		} catch {
			fatalError("Could not decode mock base45 string: \(error.localizedDescription)")
		}
	}
}
#endif
