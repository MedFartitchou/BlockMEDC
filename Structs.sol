// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SharedStructs {
    // M_Authority.sol
    struct PKI_Certificate {
        address identity;
        bytes32 publicKey;
        uint expiry;
        bool revoked;
        bool registered;
    }

    // University.sol
    struct U_institution {
        bool registered;    // register an Institution of university
        address head;
        address vice_head;
    }
    struct A_Institution {
        bool registered;  // register an Assistant Institution for trainer of university
        address head;
        address admin;
    }

    // Institution.sol
    struct Student {
        bytes32 id;    // id of student
        bool registered; // register in university as student
        uint accomplished; // complete a degree certificate (Deug, licence, master)
        mapping(bytes32 => TranscriptCer) trans; // transcript of student
        mapping(bytes32 => Acdiploma) diploms;  // diploma of student
    }
    struct Professor {
        bool registered; // register in university as professor
        address Professor;
        bytes32 id;
        bytes32 Department;
    }
    struct Admin {
        bool registered; // register in university as admin
        address Admin;
        bytes32 id;
    }

    struct TranscriptCer {
        address issuer;
        address receiver;
        bytes32 Degre;
        bytes32 Semstre;
        uint score;
        uint date;
        uint note;
        bool status;
    }

    struct Acdiploma {
        address issuer_dean;
        address issuer_president;
        address receiver;
        bytes32 Degre;
        uint date;
        uint note;
        bool status;
    }

    // A_Institution.sol
    struct TrStudent {
        bytes32 id;    // id of student
        bool registered; // register in Assistant Institution as trainer student
        uint accomplished; // complete a specific internship program
        mapping(bytes32 => Prdiploma) diplomsPr;  // Prdiploma of student
    }
    struct Prdiploma {
        address issuer_head;
        address issuer_Institution;
        address receiver;
        bytes32 Degre;
        uint period;
        bool status;
        uint date;
    }
}
