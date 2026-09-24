@echo off
setlocal DisableDelayedExpansion

rem Run from the empty directory that will become the workspace.
for /f "delims=" %%F in ('dir /a /b 2^>nul') do (
    echo Error: Directory is not empty! Execution aborted.
    exit /b 1
)

set /p "ATELIERB_PATH=Please enter the installation path for Atelier B 24.04.2: "
if not defined ATELIERB_PATH (
    echo Error: The path cannot be empty!
    exit /b 1
)
if not exist "%ATELIERB_PATH%\NUL" (
    echo Error: The installation directory does not exist.
    exit /b 1
)

rem Atelier B resource files use forward slashes in paths.
set "ATELIERB_PATH=%ATELIERB_PATH:\=/%"
set "BDB_ABS_PATH=%CD:\=/%/bdb"
mkdir "bdb" || exit /b 1
mkdir "Archives" || exit /b 1

> "AtelierB" echo(!===========================================================================
>> "AtelierB" echo(! AtelierB Global resources
>> "AtelierB" echo(!===========================================================================
>> "AtelierB" echo(!
>> "AtelierB" echo(! Tools resources
>> "AtelierB" echo(!
>> "AtelierB" echo(ATB*ATB*Logic_Solver_Command:krt -a c70000d3000e100g10000h10000m10000000n130000o110400s60000t1100x5000y5500
>> "AtelierB" echo(ATB*ATB*TypeChecker_Command:TC.kin
>> "AtelierB" echo(ATB*ATB*Xref_Command:xref
>> "AtelierB" echo(ATB*ATB*Proof_Obligations_Generator_Command:PO.kin
>> "AtelierB" echo(ATB*ATB*Proof_Obligations_Generator_NG_Command:pog
>> "AtelierB" echo(ATB*ATB*Proof_Obligations_Generator_EvB_Command:pogevb
>> "AtelierB" echo(ATB*ATB*Proof_Obligations_Generator_NG:TRUE
>> "AtelierB" echo(ATB*ATB*Binst_Command:binst
>> "AtelierB" echo(ATB*ATB*Prover_Command:MU.kin
>> "AtelierB" echo(ATB*ATB*KParser_Command:pk -a m20000
>> "AtelierB" echo(ATB*ATB*Predicate_Prover_Command:PP.kin
>> "AtelierB" echo(ATB*ATB*BED_Command:bed
>> "AtelierB" echo(ATB*ATB*Read_PMI_Command:READPMI.kin
>> "AtelierB" echo(ATB*ATB*ML_Command:ML.kin
>> "AtelierB" echo(ATB*ATB*ComenC_Translator_Command:b2c
>> "AtelierB" echo(ATB*ATB*Delta_Component_Command:DELTA3.kin
>> "AtelierB" echo(ATB*ATB*Bart_Refiner_Command:bart
>> "AtelierB" echo(ATB*ATB*BBeautifuler_Command:BBeautifuler
>> "AtelierB" echo(ATB*ATB*Print_Command:bprint
>> "AtelierB" echo(ATB*ATB*Bxml_Command:bxml
>> "AtelierB" echo(ATB*ATB*B_Compiler_Command:bcomp
>> "AtelierB" echo(ATB*ATB*External_Proof_Command:extprove
>> "AtelierB" echo(ATB*ATB*Replay_External_Proof_Command:extreplay
>> "AtelierB" echo(ATB*ATB*Proof_Metrics:extmetrics
>> "AtelierB" echo(ATB*ATB*Rust_Translator_Command:b2rust
>> "AtelierB" echo(
>> "AtelierB" echo(!===========================================================================
>> "AtelierB" echo(! TypeChecker Resource : Enable Local Operations
>> "AtelierB" echo(!===========================================================================
>> "AtelierB" echo(ATB*TC*Enable_Local_Operations:TRUE
>> "AtelierB" echo(
>> "AtelierB" echo(! Set to true not to use prover extensions defined in the 3.7 version
>> "AtelierB" echo(ATB*PR*Pr_3_6_compatibility:FALSE
>> "AtelierB" echo(
>> "AtelierB" echo(!===========================================================================
>> "AtelierB" echo(! Resources to use third-party provers
>> "AtelierB" echo(!===========================================================================
>> "AtelierB" echo(ATB*Proof*Why3Writer:po2why
>> "AtelierB" echo(ATB*Proof*Pog_Smt_Simplified_Encode:pog2smt
>> "AtelierB" echo(ATB*Proof*Pog_Smt_PP_Encode:ppTransSmt
>> "AtelierB" echo(ATB*Proof*Smt_Simplified_Read_Status:simple_smt_solver_reader
>> "AtelierB" echo(ATB*Proof*Smt_Read_Status:smt_solver_reader
>> "AtelierB" echo(ATB*Proof*Pog_TPTP_PP_Encode:ppTransTPTP
>> "AtelierB" echo(ATB*Proof*TPTP_Read_Status:tptp_reader
>> "AtelierB" echo(ATB*Proof*Pog_Why_Encode:pog2why
>> "AtelierB" echo(ATB*Proof*AltErgo_Read_Status:altergo_reader
>> "AtelierB" echo(!===========================================================================
>> "AtelierB" echo(! Installation path dependent resources
>> "AtelierB" echo(!===========================================================================
>> "AtelierB" echo(ATB*BART*RefinerFile:%ATELIERB_PATH%\share\bart\PatchRaffiner.rmf
>> "AtelierB" echo(ATB*B2RUST*Configuration_Directory:%ATELIERB_PATH%\share\b2rust\config\
>> "AtelierB" echo(ATB*ATB*Atelier_Database_Directory:%BDB_ABS_PATH%
if errorlevel 1 (
    echo Error: Could not write the AtelierB configuration file.
    exit /b 1
)
echo Success: 'bdb', 'Archives', and the 'AtelierB' configuration file have been created.
exit /b 0
