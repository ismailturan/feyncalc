(* ::Package:: *)

(* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

(* :Title: DiracReduce														*)

(*
	This software is covered by the GNU General Public License 3.
	Copyright (C) 1990-2019 Rolf Mertig
	Copyright (C) 1997-2019 Frederik Orellana
	Copyright (C) 2014-2019 Vladyslav Shtabovenko
*)

(* :Summary:  SPVAT decomposition of Dirac matrix chains					*)

(* ------------------------------------------------------------------------ *)


DiracReduce::usage =
"DiracReduce[exp] reduces all four-dimensional Dirac matrices in exp \
to the standard basis (S,P,V,A,T) using the Chisholm identity (see Chisholm). \
In the result the basic Dirac structures are wrapped with a head \
DiracBasis. I.e.: S corresponds to DiracBasis[1], \
P : DiracBasis[GA[5]], \
V : DiracBasis[GA[mu]], A: DiracBasis[GA[mu, 5]], \
T: DiracBasis[DiracSigma[GA[mu, nu]]]. \
By default DiracBasis is substituted to Identity. \n
Notice that the result of DiracReduce is given in the FeynCalcExternal-way, \
i.e., evtl. you may have to use FeynCalcInternal on result.";

(* ------------------------------------------------------------------------ *)

Begin["`Package`"]
End[]

Begin["`DiracReduce`Private`"]

drVerbose::usage="";

Options[DiracReduce] = {
	Contract 			-> True,
	DiracGammaCombine	-> True,
	DiracSimplify		-> False,
	DotSimplify			-> True,
	FCE					-> False,
	FCI					-> False,
	FCVerbose			-> False,
	Factoring			-> False,
	FinalSubstitutions	-> {DiracBasis -> Identity}
};

DiracReduce[expr_List, opts:OptionsPattern[]] :=
	Map[DiracReduce[#,opts]&,expr];

DiracReduce[expr_, OptionsPattern[]] :=
	Block[ {ex, tmp, spart, null1, null2, res, finsub, factoring,diracSimplify, li1, li2},

		finsub = OptionValue[FinalSubstitutions];
		factoring = OptionValue[Factoring];
		diracSimplify = OptionValue[DiracSimplify];

		If[	OptionValue[FCVerbose]===False,
			drVerbose=$VeryVerbose,
			If[MatchQ[OptionValue[FCVerbose], _Integer],
				drVerbose=OptionValue[FCVerbose]
			];
		];


		If[ OptionValue[FCI],
			ex = expr,
			ex = FCI[expr]
		];

		FCPrint[1, "DiracReduce. Entering.", FCDoControl->drVerbose];
		FCPrint[3, "DiracReduce: Entering with ", ex, FCDoControl->drVerbose];

		If[ FreeQ2[ex,DiracHeadsList],
			Return[ex]
		];

		tmp = ex /. {DiracGamma[6] :> (1/2 + DiracGamma[5]/2), DiracGamma[7] :> (1/2 - DiracGamma[5]/2)};

		If[	OptionValue[DiracGammaCombine],
			tmp = DiracGammaCombine[tmp,FCI->True]
		];

		If[	OptionValue[DotSimplify],
			tmp = DotSimplify[tmp,FCI->True]
		];

		(* Chisholm identity recursively *)
		tmp = Chisholm[tmp,FCI->True, DiracSimplify -> False];
		FCPrint[3, "DiracReduce: After Chisholm: ", tmp, FCDoControl->drVerbose];

		tmp = DiracOrder[tmp, FCI->True];
		FCPrint[3, "DiracReduce: After DiracOrder: ", tmp, FCDoControl->drVerbose];

		tmp = Chisholm[tmp,FCI->True,DiracSimplify->False,Mode->2];
		FCPrint[3, "DiracReduce: After Chisholm: ", tmp, FCDoControl->drVerbose];

		tmp = tmp /. DOT[DiracGamma[a_[xx_]], DiracGamma[b_[yy_]]] :> (-I DiracSigma[DiracGamma[a[xx]], DiracGamma[b[yy]]]+Pair[b[yy], a[xx]]);
		FCPrint[3, "DiracReduce: After introducing DiracSigma: ", tmp, FCDoControl->drVerbose];

		If[	diracSimplify,
			tmp = DiracSimplify[tmp, DiracSigmaExplicit -> False, FCI->True];
			FCPrint[3, "DiracReduce: After DiracSimplify: ", tmp, FCDoControl->drVerbose]
		];

		tmp = Collect2[tmp, DiracGamma, Factoring -> factoring];
		FCPrint[2,"collecting done"];

		(* get the S - part *)
		spart = SelectFree[tmp + null1 + null2, DiracGamma] /. null1|null2 :> 0;
		tmp = tmp - spart;

		If[ factoring === False,
			spart = Expand[spart] DiracBasis[1],
			If[ factoring === True,
				spart = Factor2[spart] DiracBasis[1],
				spart = factoring[spart] DiracBasis[1]
			]
		];


		res = spart + (tmp /. DiracSigma[a__] :> DiracBasis[DiracSigma[a]] /.
								DOT[DiracGamma[a_], DiracGamma[5]] :>
								DiracBasis[DOT[DiracGamma[a], DiracGamma[5]]] /.
								DiracGamma[a_] :> DiracBasis[DiracGamma[a]]);
		res = res /. finsub /. finsub;

		If[	OptionValue[DotSimplify],
			res = DotSimplify[res,FCI->True]
		];

		If[	OptionValue[Contract],
			res = Contract[res,FCI->True]
		];

		If[OptionValue[FCE],
			res = FCE[res]
		];

		res
	];

FCPrint[1,"DiracReduce.m loaded."];
End[]
