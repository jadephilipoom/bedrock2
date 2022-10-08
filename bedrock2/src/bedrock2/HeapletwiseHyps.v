Require Import Coq.Logic.PropExtensionality Coq.Logic.FunctionalExtensionality.
Require Import Coq.Lists.List. Import ListNotations. Open Scope list_scope.
Require Import coqutil.Map.Interface coqutil.Map.Properties.
Require Import coqutil.Tactics.fwd.
Require Import coqutil.Tactics.Tactics.
Require Import coqutil.Tactics.syntactic_unify.
Require Import bedrock2.Lift1Prop.
Require Import bedrock2.Map.DisjointUnion.
Require Import bedrock2.Map.SeparationLogic.

(* to mark hypotheses about heaplets *)
Definition with_mem{mem: Type}(m: mem)(P: mem -> Prop): Prop := P m.

Declare Scope heapletwise_scope.
Open Scope heapletwise_scope.

Notation "m |= P" := (with_mem m P) (at level 72) : heapletwise_scope.

Notation "m 'is' 'split' 'into' m1 , .. , m2 , m3" :=
  (Some m = mmap.dus (cons (Some m1) .. (cons (Some m2) (cons (Some m3) nil)) ..))
  (at level 10, m1 at level 0, m2 at level 0, m3 at level 0)
: heapletwise_scope.

Section HeapletwiseHyps.
  Context {key value: Type} {mem: map.map key value} {mem_ok: map.ok mem}
          {key_eqb: key -> key -> bool} {key_eqb_spec: EqDecider key_eqb}.

  Lemma split_du: forall (m m1 m2: mem),
      map.split m m1 m2 <-> Some m = mmap.du (Some m1) (Some m2).
  Proof.
    unfold map.split, mmap.du, map.du. split; intros; fwd.
    - eapply map.disjointb_spec in Hp1. rewrite Hp1. reflexivity.
    - eapply map.disjointb_spec in E. auto.
  Qed.

  Definition anymem: mem -> Prop := fun _ => True.

  Definition wand(P1 P2: mem -> Prop): mem -> Prop :=
    fun mdiff => forall m1 m2, map.split m2 mdiff m1 -> P1 m1 -> P2 m2.

  (* with mmap.du instead of map.split: *)
  Definition wand'(P1 P2: mem -> Prop): mem -> Prop :=
    fun mdiff => forall m1 m2, Some m2 = mmap.du (Some mdiff) (Some m1) -> P1 m1 -> P2 m2.

  Lemma wand_alt: wand = wand'.
  Proof.
    extensionality P. extensionality Q. extensionality m.
    eapply propositional_extensionality. unfold wand, wand';
      split; intros; eapply split_du in H0; eauto.
  Qed.

  Lemma wand_adjoint: forall (P Q R: mem -> Prop),
      impl1 (sep P Q) R <-> impl1 P (wand Q R).
  Proof.
    unfold impl1, sep, wand. intros; split; intros; fwd; eauto 7.
  Qed.

  (* modus ponens for wand only holds in one direction! *)
  Lemma wand_mp: forall P Q,
      impl1 (sep P (wand P Q)) Q.
  Proof.
    intros. rewrite sep_comm. rewrite (wand_adjoint (wand P Q) P Q). reflexivity.
  Qed.

  Lemma ramify_funspec_hyp: forall (calleePre calleePost callerPost: mem -> Prop) m,
      (* non-ramified hypothesis: requires creating an evar for Frame too early *)
      (exists Frame,
          sep calleePre Frame m /\ (forall m', sep calleePost Frame m' -> callerPost m')) <->
      (* ramified hypothesis: no frame needed *)
      sep calleePre (wand calleePost callerPost) m.
  Proof.
    split; intros; fwd.
    - revert m Hp0.
      change (impl1 (sep calleePre Frame) (sep calleePre (wand calleePost callerPost))).
      reify_goal. ecancel_step_by_implication. cbn [seps].
      eapply (wand_adjoint Frame calleePost callerPost). rewrite sep_comm. unfold impl1.
      exact Hp1.
    - eexists. split. 1: exact H.
      change (impl1 (sep calleePost (wand calleePost callerPost)) callerPost).
      eapply wand_mp.
  Qed.

  Lemma sep_assoc_eq: forall (p q r: mem -> Prop),
      sep (sep p q) r = sep p (sep q r).
  Proof.
    intros. eapply iff1ToEq. eapply sep_assoc.
  Qed.

  Lemma sep_to_with_mem_and_with_mem: forall (P Q: mem -> Prop) m,
      sep P Q m ->
      exists m1 m2, with_mem m1 P /\ with_mem m2 Q /\ Some m = mmap.du (Some m1) (Some m2).
  Proof.
    unfold with_mem, sep, map.split. intros. fwd. do 2 eexists. ssplit.
    1,2: eassumption.
    simpl. unfold map.du. eapply map.disjointb_spec in Hp0p1. rewrite Hp0p1.
    reflexivity.
  Qed.

  Lemma sep_to_with_mem_and_unpacked: forall (P Q: mem -> Prop) m,
      sep P Q m ->
      exists m1 m2, with_mem m1 P /\ Q m2 /\ Some m = mmap.du (Some m1) (Some m2).
  Proof. exact sep_to_with_mem_and_with_mem. Qed.

  Lemma sep_to_unpacked_and_with_mem: forall (P Q: mem -> Prop) m,
      sep P Q m ->
      exists m1 m2, P m1 /\ with_mem m2 Q /\ Some m = mmap.du (Some m1) (Some m2).
  Proof. exact sep_to_with_mem_and_with_mem. Qed.

  Lemma sep_to_unpacked_and_unpacked: forall (P Q: mem -> Prop) m,
      sep P Q m ->
      exists m1 m2, P m1 /\ Q m2 /\ Some m = mmap.du (Some m1) (Some m2).
  Proof. exact sep_to_with_mem_and_with_mem. Qed.

  Definition canceling(Ps: list (mem -> Prop))(oms: list (option mem))(Rest: Prop): Prop :=
    (forall m, Some m = mmap.dus oms -> seps Ps m) /\ Rest.

  Lemma canceling_equiv_heaplets: forall Ps oms1 oms2 Rest,
      mmap.dus oms1 = mmap.dus oms2 ->
      canceling Ps oms1 Rest ->
      canceling Ps oms2 Rest.
  Proof. unfold canceling. intros. rewrite <- H. assumption. Qed.

  Lemma canceling_start_and: forall {Ps oms m Rest},
      Some m = mmap.dus oms ->
      canceling Ps oms Rest ->
      seps Ps m /\ Rest.
  Proof.
    unfold canceling. intros. fwd. eauto.
  Qed.

  Lemma canceling_start_noand: forall {Ps oms m},
      Some m = mmap.dus oms ->
      canceling Ps oms True ->
      seps Ps m.
  Proof.
    unfold canceling. intros. fwd. eauto.
  Qed.

  Lemma canceling_done_empty: canceling [] [] True.
  Proof.
    unfold canceling. simpl. intros. split. 2: constructor.
    intros. inversion H. unfold emp. auto.
  Qed.

  Lemma canceling_done_anymem: forall {oms} {Rest: Prop},
      Rest -> canceling [anymem] oms Rest.
  Proof.
    unfold canceling, anymem. simpl. intros. auto.
  Qed.

  (* used to instantiate the frame with a magic wand
     (ramification trick to avoid evar scoping issues) *)
  Lemma canceling_done_frame_wand: forall oms (calleePost callerPost: mem -> Prop),
      let F := (wand calleePost callerPost) in
      (forall mFrame, Some mFrame = mmap.dus oms -> F mFrame) ->
      canceling [F] oms (forall m', sep calleePost F m' -> callerPost m').
  Proof.
    unfold canceling. cbn [seps]. intros. split. 1: assumption.
    change (impl1 (sep calleePost (wand calleePost callerPost)) callerPost).
    eapply wand_mp.
  Qed.

  (* used to instantiate the frame with an unfolded magic wand
     (ramification trick to avoid evar scoping issues) *)
  Lemma canceling_done_frame: forall oms (calleePost callerPost: mem -> Prop),
      (forall mNew mModified,
          Some mNew = mmap.du (mmap.dus oms) (Some mModified) ->
          calleePost mModified -> callerPost mNew) ->
      (* F is (wand calleePost callerPost) unfolded *)
      let F := (fun mFrame => forall mModified mNew,
                    Some mNew = mmap.du (Some mFrame) (Some mModified) ->
                    calleePost mModified -> callerPost mNew) in
      canceling [F] oms (forall m', sep calleePost F m' -> callerPost m').
  Proof.
    intros.
    pose proof (canceling_done_frame_wand oms calleePost callerPost) as P.
    rewrite wand_alt in P. eapply P. clear P F.
    unfold wand'. intros. eapply H. 2: eassumption. rewrite <- H0. assumption.
  Qed.

  (* Separate definitions to avoid simplifying user-defined expressions that
     use the definitions from the standard library: *)
  Definition heaplets_hd: list (option mem) -> option mem :=
    Eval cbv delta in (@List.hd (option mem) None).
  Definition heaplets_tl: list (option mem) -> list (option mem) :=
    Eval cbv delta in (@List.tl (option mem)).
  Definition heaplets_firstn: nat -> list (option mem) -> list (option mem) :=
    Eval cbv delta in (@List.firstn (option mem)).
  Definition heaplets_skipn: nat -> list (option mem) -> list (option mem) :=
    Eval cbv delta in (@List.skipn (option mem)).
  Definition heaplets_app: list (option mem) -> list (option mem) -> list (option mem) :=
    Eval cbv delta in (@List.app (option mem)).
  Definition heaplets_nth(n: nat)(xs: list (option mem)): option mem :=
    heaplets_hd (skipn n xs).
  Definition heaplets_remove_nth(n: nat)(xs : list (option mem)): list (option mem) :=
    heaplets_app (heaplets_firstn n xs) (heaplets_tl (heaplets_skipn n xs)).

  Lemma cancel_head: forall n {P: mem -> Prop} {Ps oms mn Rest},
      with_mem mn P ->
      heaplets_nth n oms = Some mn ->
      canceling Ps (heaplets_remove_nth n oms) Rest ->
      canceling (P :: Ps) oms Rest.
  Proof.
    unfold with_mem, canceling. intros. destruct H1 as [H1 HR]. split; [intros |exact HR].
    eapply seps_cons.
    pose proof dus_remove_nth as A. specialize A with (1 := H0) (2 := H2).
    fwd.
    specialize H1 with (1 := Ap0).
    unfold sep. do 2 eexists. ssplit. 2,3: eassumption.
    unfold map.split. unfold map.du in Ap1. fwd.
    eapply map.disjointb_spec in E. auto.
  Qed.

  (* for home-made rewrite *)
  Lemma subst_mem_eq(mSmall mBig: mem){rhsSmall: option mem}(C: option mem -> option mem):
    Some mSmall = rhsSmall ->
    Some mBig = C (Some mSmall) ->
    Some mBig = C rhsSmall.
  Proof. intros. rewrite H in H0. exact H0. Qed.
End HeapletwiseHyps.

Ltac cbn_heaplets :=
  cbn [heaplets_hd heaplets_tl heaplets_firstn heaplets_skipn
       heaplets_app heaplets_nth heaplets_remove_nth].

Ltac reify_dus e :=
  lazymatch e with
  | mmap.du ?h ?t => let rt := reify_dus t in constr:(cons h rt)
  | _ => constr:(cons e nil)
  end.

Ltac reify_seps e :=
  lazymatch e with
  | sep ?h ?t => let rt := reify_seps t in constr:(cons h rt)
  | _ => constr:(cons e nil)
  end.


Ltac should_unpack P :=
 lazymatch P with
 | sep _ _ => constr:(true)
 | (fun m => Some m = _) => constr:(true)
 | _ => constr:(false)
 end.

Ltac replace_with_new_mem_hyp H :=
  lazymatch type of H with
  | with_mem _ (?pred ?val ?addr) =>
      lazymatch reverse goal with
      | HOld: with_mem ?mOld (pred ?newval addr) |- _ =>
          move H before HOld;
          clear mOld HOld;
          rename H into HOld
      end
  end.

Ltac split_sep_step :=
  let D := fresh "D" in
  let m1 := fresh "m0" in
  let m2 := fresh "m0" in
  let H1 := fresh "H0" in
  let H2 := fresh "H0" in
  lazymatch goal with
  | H: @sep _ _ ?mem ?P ?Q ?parent_m |- _ =>
      let unpackP := should_unpack P in
      let unpackQ := should_unpack Q in
      lazymatch constr:((unpackP, unpackQ)) with
      | (true, true) => eapply sep_to_unpacked_and_unpacked in H
      | (false, true) => eapply sep_to_with_mem_and_unpacked in H
      | (true, false) => eapply sep_to_unpacked_and_with_mem in H
      | (false, false) => eapply sep_to_with_mem_and_with_mem in H
      end;
      destruct H as (m1 & m2 & H1 & H2 & D);
      move m1 before parent_m; (* before in direction of movement == below *)
      move m2 before m1;
      try replace_with_new_mem_hyp H1;
      try replace_with_new_mem_hyp H2;
      let E := match goal with
               | E: @Some (@map.rep _ _ mem) ?mBig = ?rhs |- _ =>
                   lazymatch rhs with
                   | context C[Some parent_m] => E
                   end
               | |- _ => constr:(tt) (* in first sep destruct step, there's no E yet *)
               end in
      (* re-match, but this time lazily, to preserve error messages: *)
      lazymatch type of E with
      | @Some (@map.rep _ _ mem) ?mBig = ?rhs =>
          lazymatch rhs with
          | context C[Some parent_m] =>
              (* home-made rewrite in hyp because we already have context C *)
              eapply (subst_mem_eq parent_m mBig
                        (fun hole: option mem =>
                           ltac:(let r := context C[hole] in exact r))
                        D) in E;
              (* (Some parent_m) might also appear in below the line (if canceling) *)
              rewrite ?D;
              clear parent_m D
          end
      | unit => idtac
      end
  end.

Ltac reify_disjointness_hyp :=
  lazymatch goal with
  | D: Some ?m = mmap.du _ _ |- _ =>
      rewrite ?mmap.du_assoc in D;
      let e := lazymatch type of D with Some m = ?e => e end in
      let memlist := reify_dus e in
      change (Some m = mmap.dus memlist) in D
  | D: Some ?m = mmap.dus ?oms |- _ =>
      lazymatch oms with
      | context[mmap.du _ _] =>
          cbn [mmap.dus] in D
          (* and next iteration will actually reify it *)
      end
  end.

Ltac rereify_canceling_heaplets :=
  lazymatch goal with
  | |- canceling _ ?oms _ =>
      lazymatch oms with
      | context[mmap.du _ _] => eapply canceling_equiv_heaplets
      end
  end;
  [ cbn [mmap.dus];
    rewrite ?mmap.du_assoc;
    lazymatch goal with
    | |- mmap.dus ?e = ?rhs =>
        is_evar e;
        let r := reify_dus rhs in unify e r
    end;
    reflexivity
  | ].

Ltac start_canceling :=
  rewrite ?sep_assoc_eq;
  (* TODO support multiple D's and a way to pick the right one *)
  lazymatch goal with
  | D: Some ?m = mmap.dus _ |- sep ?eh ?et ?m /\ ?Rest =>
      let clauselist := reify_seps (sep eh et) in change (seps clauselist m /\ Rest);
      eapply (canceling_start_and D)
  | D: Some ?m = mmap.dus _ |- sep ?eh ?et ?m =>
      let clauselist := reify_seps (sep eh et) in change (seps clauselist m);
      eapply (canceling_start_noand D)
  end.

Ltac index_of_Some m oms :=
  lazymatch oms with
  | cons (Some m) _ => constr:(O)
  | cons _ ?tl => let n := index_of_Some m tl in constr:(S n)
  end.

Ltac canceling_step :=
  lazymatch goal with
  | |- canceling (cons ?P ?Ps) ?oms ?Rest =>
      tryif is_evar P then fail "reached frame (or other evar)" else
      let H := match goal with
               | H: with_mem _ ?P' |- _ =>
                   let __ := match constr:(Set) with _ => syntactic_unify P' P end in H
               end in
      let m := lazymatch type of H with with_mem ?m _ => m end in
      let oms := lazymatch goal with |- canceling _ ?oms _ => oms end in
      let n := index_of_Some m oms in
      eapply (cancel_head n H); [ reflexivity | cbn_heaplets ]
  end.

Ltac canceling_done :=
  lazymatch goal with
  | |- canceling [] [] True => eapply canceling_done_empty
  | |- canceling [anymem] _ _ => eapply canceling_done_anymem
  | |- canceling [?e] _ _ =>
      is_evar e;
      (* expose frame evar *)
      repeat match goal with
        | |- context[sep ?a (sep ?b ?c)] =>
            has_evar c;
            rewrite <- (sep_assoc_eq a b c)
        end;
      (* TODO: currently, callee post must have specific shape matching
         canceling_done_frame's conclusion, can we generalize it? *)
      eapply canceling_done_frame
  end.

Ltac clear_unused_mem_hyps_step :=
  match goal with
  | H: with_mem ?m _ |- _ => clear m H
  end.

Ltac intro_step :=
  lazymatch goal with
  | m: ?mem, H: @with_mem ?mem _ _ |- forall (_: ?mem), _ =>
      let m' := fresh "m0" in intro m'; move m' before m
  | HOld: Some ?mOld = mmap.dus _ |- Some _ = mmap.du _ _ -> _ =>
      let tmp := fresh "tmp" in
      intro tmp; move tmp before HOld; clear mOld HOld; rename tmp into HOld;
      cbn [mmap.dus] in HOld
  | H: with_mem _ _ |- sep _ _ _ -> _ =>
      let H' := fresh "H0" in
      intro H'; move H' before H
  | H: with_mem ?mOld (?pred ?oldVal ?addr) |- ?pred ?newVal ?addr ?mNew -> _ =>
      let tmp := fresh "tmp" in
      intro tmp;
      move tmp before H;
      clear H mOld;
      rename tmp into H;
      change (with_mem mNew (pred newVal addr)) in H
  end.

Ltac and_step :=
  lazymatch goal with
  | |- (fun _ => _ /\ _) _ /\ _ => cbv beta
  | |- (_ /\ _) /\ _ => eapply and_assoc
  end.

Ltac heapletwise_step :=
  first
    [ intro_step
    | split_sep_step
    | reify_disjointness_hyp
    | and_step
    | start_canceling
    | rereify_canceling_heaplets
    | canceling_step
    | canceling_done ].

Ltac underscorify_except_last_hyp e :=
  lazymatch type of e with
  | forall _ _, _ => underscorify_except_last_hyp open_constr:(e _)
  | _ => e
  end.

(* Given a goal of the form `?calleePre m -> WP args post` and a callee spec,
   unifies the last hyp of the spec with `?calleePre m` and applies the spec.
   (If Coq's eapply/unify/rapply was more powerful, this tactic would not be needed) *)
Ltac apply_funspec spec :=
  let p := underscorify_except_last_hyp spec in
  lazymatch type of p with
  | ?A -> ?B =>
      let m := lazymatch A with
               | context[sep _ _ ?m] => m
               end in
      let A' := eval pattern m in A in
      let p' := open_constr:(p: A' -> B) in
      exact p'
  end.

Section HeapletwiseHypsTests.
  Context {key value: Type} {mem: map.map key value} {mem_ok: map.ok mem}
          {key_eqb: key -> key -> bool} {key_eqb_spec: EqDecider key_eqb}.

  Hypothesis scalar: nat -> nat -> mem -> Prop.

  Goal forall m v1 v2 v3 v4 (Rest: mem -> Prop),
      (sep (scalar v1 1) (sep (sep (scalar v2 2) (scalar v3 3)) (sep (scalar v4 4) Rest))) m ->
      exists R a4 a3, sep (sep (scalar a4 4) (scalar a3 3)) R m.
  Proof.
    intros.
    repeat heapletwise_step.
    do 3 eexists.
    start_canceling.

(*
  m, m0, m6, m7, m4, m5 : mem
  v1, v2, v3, v4 : nat
  Rest : mem -> Prop
  H0 : m0 |= scalar v1 1
  H3 : m6 |= scalar v2 2
  H5 : m7 |= scalar v3 3
  H1 : m4 |= scalar v4 4
  H4 : m5 |= Rest
  ============================
  canceling [scalar ?a4 4; scalar ?a3 3; ?R] [Some m0; Some m6; Some m7; Some m4; Some m5] True
*)

    repeat canceling_step.
    eapply (canceling_done_anymem I).
  Qed.

  Context (cmd: Type).
  Context (wp: cmd -> mem -> (mem -> Prop) -> Prop).
  Hypothesis wp_weaken: forall c m (P Q: mem -> Prop),
      wp c m P ->
      (forall m', P m' -> Q m') ->
      wp c m Q.

  Lemma sep_call: forall funcall m (calleePre calleePost callerPost: mem -> Prop),
      (calleePre m -> wp funcall m (fun m' => calleePost m')) ->
      (calleePre m /\ forall m', calleePost m' -> callerPost m') ->
      wp funcall m callerPost.
  Proof.
    intros. fwd. eapply wp_weaken.
    - eapply H. assumption.
    - cbv beta. assumption.
  Qed.

  Context (frobenicate: nat -> nat -> cmd).
  Context (frobenicate_ok: forall (a1 a2 v1 v2: nat) (m: mem) (R: mem -> Prop),
              sep (scalar v1 a1) (sep (scalar v2 a2) R) m ->
              wp (frobenicate a1 a2) m (fun m' =>
                   sep (scalar (v1 + v2) a1) (sep (scalar (v1 - v2) a2) R) m')).

  (* sample caller: *)
  Goal forall (p1 p2 p3 x y: nat) (m: mem) (R: mem -> Prop),
      sep (scalar x p1) (sep (scalar y p2) (sep (scalar x p3) R)) m ->
      wp (frobenicate p1 p3) m (fun m' =>
        wp (frobenicate p3 p1) m' (fun m'' =>
           sep (scalar 0 p1) (sep (scalar y p2) (sep (scalar (x + x) p3) R)) m'')).
  Proof.
    intros.
    repeat heapletwise_step.

    eapply sep_call. 1: eapply frobenicate_ok.
    repeat heapletwise_step.
    eapply sep_call. 1: eapply frobenicate_ok.
    repeat heapletwise_step.

    rewrite PeanoNat.Nat.sub_diag in *.
    rewrite PeanoNat.Nat.add_0_l in *.
    rewrite PeanoNat.Nat.sub_0_l in *.

    repeat heapletwise_step.
  Qed.

  Let scalar_pair(v1 v2 a1 a2: nat) := sep (scalar v1 a1) (scalar v2 a2).

  (* sample caller where argument is a field: *)
  Goal forall (p1 p2 p3 x y: nat) (m: mem) (R: mem -> Prop),
      sep (scalar x p1) (sep (scalar_pair y x p2 p3) R) m ->
      wp (frobenicate p1 p3) m (fun m' =>
        wp (frobenicate p3 p1) m' (fun m'' =>
           sep (scalar 0 p1) (sep (scalar_pair y (x + x) p2 p3) R) m'')).
  Proof.
    intros.
    repeat heapletwise_step.
    eapply sep_call. 1: eapply frobenicate_ok.
    repeat heapletwise_step.

    (* unfolding/splitting hyp during cancellation: *)
    unfold scalar_pair in H2.
    unfold with_mem in H2.

    repeat heapletwise_step.

    eapply sep_call. 1: eapply frobenicate_ok.
    repeat heapletwise_step.

    rewrite PeanoNat.Nat.sub_diag in *.
    rewrite PeanoNat.Nat.add_0_l in *.
    rewrite PeanoNat.Nat.sub_0_l in *.

    repeat heapletwise_step.

    (* TODO refold scalar_pair after its update, and/or unfold scalar_pair in goal *)
  Abort.

  Context (aliasing_add: nat -> nat -> nat -> cmd).
  Hypothesis aliasing_add_ok: forall a b c va vb vc (R: mem -> Prop) m,
      sep (scalar va a) anymem m /\
      sep (scalar vb b) anymem m /\
      sep (scalar vc c) R m ->
      wp (aliasing_add c a b) m (fun m' =>
        sep (scalar (va + vb) c) R m').

  Goal forall x y z vx vy vz (R: mem -> Prop) m,
      sep (scalar vx x) (sep (scalar vy y) (sep (scalar vz z) R)) m ->
      wp (aliasing_add x y z) m (fun m =>
        wp (aliasing_add x y y) m (fun m =>
          wp (aliasing_add x x z) m (fun m =>
            wp (aliasing_add x x x) m (fun m =>
              sep (scalar (vy + vy + vz + (vy + vy + vz)) x)
                (sep (scalar vy y) (sep (scalar vz z) R)) m)))).
  Proof.
    clear frobenicate frobenicate_ok scalar_pair.
    intros.
    repeat heapletwise_step.
    eapply sep_call. 1: apply_funspec aliasing_add_ok.
    repeat heapletwise_step.
    eapply sep_call. 1: apply_funspec aliasing_add_ok.
    repeat heapletwise_step.
    eapply sep_call. 1: apply_funspec aliasing_add_ok.
    repeat heapletwise_step.
    eapply sep_call. 1: apply_funspec aliasing_add_ok.
    repeat heapletwise_step.
  Qed.

End HeapletwiseHypsTests.