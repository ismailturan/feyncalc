(* *************************************************************** *)
(*                                                                 *)
(*                      ChPTVirtualPhotons22                       *)
(*                                                                 *)
(* *************************************************************** *)

(* 
   Author:              F.Orellana 2001

   Mathematica Version: 4.0 

   Requirements:        FeynCalc > 3, Phi 

   Summary:             Lagrangian for Phi

   Description:         The leading order ChPT lagrangian with 
                        electromagnetic couplings.
    
                        Taken from Marc Knecht and Res Urech
                        (1997), hep-ph/9709348
*)


Begin["HighEnergyPhysics`Phi`Objects`"];

ChPTVirtualPhotons22::"usage"=
"ChPT22 is the name of the file containing the definitions for 
ULagrangian[ChPT2EM[2]], which is the leading order pionic
SU(2) ChPT lagrangian with couplings to virtual photons.
To evaluate use ArgumentsSupply";

GaugeFixingParameter::"usage"=
"GaugeFixingParameter is the gauge fixing parameter of the lowest 
order electromagnetic ChPT lagrangian ChPTVirtualPhotons22, the usual choice 
is Lorentz gauge, GaugeFixingParameter=1";

(* --------------------------------------------------------------- *)

Begin["`Private`"];

(* --------------------------------------------------------------- *)

(* Abbreviations *)

fcpd:=HighEnergyPhysics`FeynCalc`PartialD`PartialD;
fcli:=HighEnergyPhysics`FeynCalc`LorentzIndex`LorentzIndex;
fcqf:=HighEnergyPhysics`FeynCalc`QuantumField`QuantumField;

mu=(Global`\[Mu]);
nu=(Global`\[Nu]);

(* ---------------------------------------------------------------- *)

(* Box definitions *)

pt/:MakeBoxes[pt[a_],TraditionalForm]:=MakeBoxes[TraditionalForm[a]];
pt/:MakeBoxes[pt[],TraditionalForm]:="";
pt/:MakeBoxes[pt[RenormalizationState[1]],TraditionalForm]:="r";
pt/:MakeBoxes[pt[RenormalizationState[0]],TraditionalForm]:="";
    
UCouplingConstant/:
  MakeBoxes[
    UCouplingConstant[ChPTVirtualPhotons2[2],st___RenormalizationState,
      sc___RenormalizationScheme,qs___QuarkMassExpansionState],
    TraditionalForm]:=
  SuperscriptBox[MakeBoxes[StyleForm["C",FontSlant->"Italic"]][[1]],
    RowBox[Join[{MakeBoxes[TraditionalForm[pt[st]]]},{
          MakeBoxes[TraditionalForm[pt[sc]]]},{
          MakeBoxes[TraditionalForm[pt[qs]]]}]]];

GaugeFixingParameter/:
MakeBoxes[GaugeFixingParameter,TraditionalForm]:=
MakeBoxes[StyleForm["\[Lambda]",FontSlant->"Italic"]][[1]];


(* --------------------------------------------------------------- *)

SetAttributes[ChPTVirtualPhotons2,NumericFunction];

(* --------------------------------------------------------------- *)

ULagrangian[ChPTVirtualPhotons2[2]]:=

1/4*DecayConstant[Pion]^2*

(UTrace[ NM[CDr[MM,{mu}],Adjoint[CDr[MM,{mu}]]] ] +

UTrace[ NM[UChiMatrix,Adjoint[MM]]+NM[Adjoint[UChiMatrix],MM] ]) -

1/4*
NM[FieldStrengthTensor[fcli[mu],
fcqf[Particle[Photon],fcli[nu]]],
FieldStrengthTensor[fcli[mu],
fcqf[Particle[Photon],fcli[nu]]]]-

GaugeFixingParameter/2*
FDr[fcqf[Particle[Photon],fcli[mu]],{mu}]*
FDr[fcqf[Particle[Photon],fcli[nu]],{nu}]+

UCouplingConstant[ChPTVirtualPhotons2[2]]*
UTrace[NM[UMatrix[UChiralSpurionRight],MM,
UMatrix[UChiralSpurionLeft],Adjoint[MM]]];
    
(* --------------------------------------------------------------- *)

FieldsSet[ChPTVirtualPhotons2[2]]:=
{IsoVector[fcqf[Particle[Pion]]],
fcqf[Particle[Photon]]};

$ULagrangians=Union[$ULagrangians,{ChPTVirtualPhotons2[2]}];

End[];

End[];
