(*
Copyright © 2006-2008 Russell O’Connor

Permission is hereby granted, free of charge, to any person obtaining a copy of
this proof and associated documentation files (the "Proof"), to deal in
the Proof without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Proof, and to permit persons to whom the Proof is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Proof.

THE PROOF IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE PROOF OR THE USE OR OTHER DEALINGS IN THE PROOF.
*)
Require Export Metric.
Require Import Prelength.
Require Import Classification.
Require Import QMinMax.
Require Import COrdAbs.
Require Import Qordfield.
Require Import Qabs.
Require Import CornTac.

Set Implicit Arguments.

Open Local Scope Q_scope.

Opaque Qabs.

(**
** Example of a Metric: <Q, Qball>
*)

Definition Qball (e : Qpos) (a b : Q) := AbsSmall (e:Q) (a - b).

Lemma Qball_Qabs : forall e a b, Qball e a b <-> Qabs (a - b) <= e.
Proof.
 intros e a b.
 unfold Qball, AbsSmall.
 simpl.
 generalize (a-b).
 intros c.
 split.
  apply Qabs_case.
   tauto.
  intros.
  rewrite <- (Qopp_involutive e).
  apply Qopp_le_compat.
  tauto.
 intros.
 split.
  apply Qle_trans with (-(Qabs (-c))).
   rewrite Qabs_opp.
   auto with *.
  rewrite <- (Qopp_involutive c).
  apply Qopp_le_compat.
  rewrite Qopp_involutive.
  apply Qle_Qabs.
 apply Qle_trans with (Qabs c); auto with *.
 apply Qle_Qabs.
Qed.

Lemma Qle_closed : (forall e x, (forall d : Qpos, x <= e+d) -> x <= e).
Proof.
 intros.
 apply: shift_zero_leEq_minus'.
 apply: inv_cancel_leEq.
 apply: approach_zero_weak;simpl.
 intros.
 replace LHS with (x[-](e:Q)).
  apply: shift_minus_leEq;simpl.
  replace RHS with (e+e0) by ring.
  rewrite <- (QposAsmkQpos H0).
  apply (H (mkQpos H0)).
 unfold cg_minus; simpl; ring.
Qed.

Notation QS  := Q_is_Setoid (only parsing).

Lemma Q_is_MetricSpace : is_MetricSpace QS Qball.
Proof.
 split.
     intros e x.
     unfold Qball.
     apply AbsSmall_wdr with 0.
      apply (zero_AbsSmall _ (e:Q)).
      apply less_leEq.
      apply Qpos_prf.
     simpl; ring.
    intros e x y.
    unfold Qball.
    apply AbsSmall_minus.
   intros [e1  He1] [e2 He2] a b c H1 H2.
   unfold Qball.
   apply AbsSmall_wdr with ((a-b)+(b-c)).
    autorewrite with QposElim.
    apply AbsSmall_plus; assumption.
   simpl; ring.
  intros e a b H.
  unfold Qball.
  split.
   apply inv_cancel_leEq;simpl.
   replace RHS with (e:Q) by ring.
   apply Qle_closed.
   intros.
   destruct (H d).
   apply: inv_cancel_leEq;simpl.
   replace RHS with (a-b) by ring.
   destruct e; destruct d; apply H0.
  apply Qle_closed.
  intros d.
  destruct (H d).
  destruct e; destruct d; apply H1.
 intros.
 apply: cg_inv_unique_2.
 apply: AbsSmall_approach_zero;simpl.
 intros e H0.
 rewrite <- (QposAsmkQpos H0).
 apply (H (mkQpos H0)).
Qed.
(* begin hide *)
Add Morphism Qball with signature QposEq ==> Qeq ==> Qeq ==> iff as Qball_wd.
Proof.
 intros [x1 Hx1] [x2 Hx2] H x3 x4 H0 x5 x6 H1.
 unfold Qball.
 unfold AbsSmall.
 simpl.
 rewrite H0.
 rewrite H1.
 unfold QposEq in H.
 simpl in H.
 rewrite H.
 tauto.
Qed.
(* end hide *)
Definition Q_as_MetricSpace : MetricSpace :=
@Build_MetricSpace QS _ Qball_wd Q_is_MetricSpace.
(* begin hide *)
Canonical Structure Q_as_MetricSpace.
(* end hide *)
Lemma QPrelengthSpace_help : forall (e d1 d2:Qpos), e < d1+d2 -> forall (a b c:QS), ball e a b -> (c == (a*d2 + b*d1)/(d1+d2)%Qpos) -> ball d1 a c.
Proof.
 intros e d1 d2 He a b c Hab Hc.
 simpl.
 unfold Qball.
 apply AbsSmall_wdr with ((d1/(d1+d2)%Qpos)*(a - b)).
  apply AbsSmall_wdl with ((d1/(d1+d2)%Qpos)*(d1+d2)%Qpos); [|simpl; field; apply Qpos_nonzero].
  apply mult_resp_AbsSmall.
   apply less_leEq.
   apply (div_resp_pos _  _ (d1:Q) (@Qpos_nonzero (d1+d2)%Qpos)); apply Qpos_prf.
  destruct d1; destruct d2; apply (AbsSmall_trans _ (e:Q)); assumption.
 simpl.
 rewrite Hc.
 pose (@Qpos_nonzero (d1 + d2)%Qpos).
 QposField.
 assumption.
Qed.

(** Q is a prelength space *)
Lemma QPrelengthSpace : PrelengthSpace Q_as_MetricSpace.
Proof.
 intros a b e d1 d2 He Hab.
 pose (c:= (a * d2 + b * d1) / (d1 + d2)%Qpos).
 exists c.
  apply (@QPrelengthSpace_help e d1 d2 He a b c); try assumption.
  reflexivity.
 apply ball_sym.
 eapply QPrelengthSpace_help.
   rewrite Qplus_comm.
   apply He.
  apply ball_sym.
  apply Hab.
 unfold c.
 unfold Qdiv.
 apply Qmult_comp.
  ring.
 apply Qinv_comp.
 QposRing.
Qed.

(** Q is a decideable metric, and hence located and stable. *)
Lemma Qmetric_dec : decidableMetric Q_as_MetricSpace.
Proof.
 intros e a b.
 simpl.
 unfold Qball, AbsSmall.
 simpl.
 set (c:=-e).
 set (d:=(a-b)).
 destruct (Qlt_le_dec_fast d c) as [Hdc|Hdc].
  right.
  abstract( intros [H1 H2]; apply (Qlt_not_le _ _ Hdc H1) ).
 destruct (Qlt_le_dec_fast e d) as [Hed|Hed].
  right.
  abstract( intros [H1 H2]; apply (Qlt_not_le _ _ Hed H2) ).
 left.
 abstract auto.
Defined.

Hint Resolve Qmetric_dec : metricQ.

Lemma locatedQ : locatedMetric Q_as_MetricSpace.
Proof.
 apply decidable_located.
 auto with *.
Defined.

Hint Resolve locatedQ : metricQ.

Lemma stableQ : stableMetric Q_as_MetricSpace.
Proof.
 apply located_stable.
 auto with *.
Qed.

Hint Resolve stableQ : metricQ.