pragma solidity ^0.4.23;
library SharedStructs{
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
        bool registered;    // registre an Institition of university 
        address head;
        address vice_head;   
    }
    struct A_Institution {
        bool registered;  // registre an Assistant Institution for trainer of university 
        address head;
        address admin;   
    }

    // Institution.sol
    struct Student {
        bytes32 id;    // id of student 
        bool registered; // registre in university as student 
        uint accomplished; // complete a degre certifacte ( Deug , licence , master )
        mapping(bytes32 => TranscriptCer) trans; // transcript of student 
        mapping(bytes32 => Acdiploma) diploms;  // diploma of student 
    }
    struct Professor {
        bool registered; // registre in university as student 
        address Professor;
        bytes32 id;
        bytes32 Department;
    }
    struct Admin {
        bool registered; // registre in university as student 
        address Admin;
        bytes32 id;
    }

    struct TranscriptCer {
        address issuer;
        address receiver;
        bytes32 Degre;
        bytes32 Semstre; 
        uint score; // date 
        uint date;
        uint note;
        bool status;
    }

    
    struct Acdiploma {
    address issuer_dean;
    address issuer_president;  // Fixed typo from 'issuer_presedent'
    address receiver;
    bytes32 Degre;
    uint date;
    uint note;
    bool status;
   }

    
    // A_Institution.sol
     struct TrStudent {
        bytes32 id;    // id of student 
        bool registered; // registre in Assistant Institution  as trainer student 
        uint accomplished; // complete a specific internship program 
        mapping(bytes32 => Prdiploma) diplomsPr;  // Prdiploma of student 
    }
      struct Prdiploma {
        address issuer_head;
        address issuer_Institution ;
        address receiver;
        bytes32 Degre;
        uint period;
        bool status;
        uint date;
    } 

} 
 
