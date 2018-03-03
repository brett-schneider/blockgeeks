pragma solidity ^0.4.14;

contract Blockgeeks {

	mapping(address => address[]) private endorsers; 
	mapping(address => mapping(string => uint64)) private balances;
	string[] private balancesLUT;

	function endorser_exists(address endorser, address endorsee) private returns (bool) {
		uint64 i = 0;
		while (i < endorsers[endorsee].length && endorsers[endorsee][i] != endorser) {
			i++;
		}
		return endorsers[endorsee][i] == endorser;
	}
	function add_endorsement(address e, address endorsee) private {
		endorsers[endorsee].push(e);
	}

	function subjectExistsAt(string s) private returns (bool x, uint i) {
		uint j = 0;
		while (keccak256(balancesLUT[j]) != keccak256(s) && j < balancesLUT.length) {
			j++;
		}
		return (keccak256(balancesLUT[j]) == keccak256(s), j);
	}
	function subjectExists(string s) private returns (bool) {
		bool x;
		uint i;
		(x,i) = subjectExistsAt(s);
		return x;
	}
	function getEndorsementsDetail(address endorsee) private returns (uint64[]) {
		uint64[] memory r;
		for (uint64 i=0;i<endorsers[endorsee].length;i++) {
			// btmp = tokenrepo.getBalances(endorsers[endorsee][i]);
			for (uint64 j=0;j<balancesLUT.length;j++) {
				r[j] += balances[endorsers[endorsee][i]][balancesLUT[j]];
			}
		}
		return r;
	}


	// external api

	function endorse(address endorsee) external returns (bool) {
		if (!endorser_exists(msg.sender, endorsee)) {
			add_endorsement(msg.sender, endorsee);
			return true;
		}
		return false;
	}
	function getEndorsementsSimple(address endorsee) external returns (uint) {
		return endorsers[endorsee].length;
	}
	function getEndorsementsFull(address endorsee) external returns (uint64[]) {
		return getEndorsementsDetail(endorsee);
	}
	function getEndorsementsTotal(address endorsee) external returns (uint64) {
		uint64 r = 0;
		uint64[] memory b = getEndorsementsDetail(endorsee);
		for (uint64 i=0;i<b.length;i++) {
			r += b[i];
		}
		return r;
	}
	function getEndorsementsForSubject(address endorsee, string subject) public returns (uint64) {
		return balances[endorsee][subject];
	}
	function proposeSubject(string s) public returns (bool) {
		return subjectExists(s);
	}
	function enterSubject(string s) public returns (bool) {
		if (subjectExists(s)) {
			balances[msg.sender][s] += 100;
		}
	}
}

