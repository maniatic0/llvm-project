; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 4
; RUN: opt -S -passes=instcombine < %s | FileCheck %s

define void @int_iv_nuw(i64 %base, i64 %end) {
; CHECK-LABEL: define void @int_iv_nuw(
; CHECK-SAME: i64 [[BASE:%.*]], i64 [[END:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[IV_NEXT:%.*]], [[LOOP]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[IV2:%.*]] = add nuw i64 [[IV]], [[BASE]]
; CHECK-NEXT:    call void @use.i64(i64 [[IV2]])
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i64 [[IV_NEXT]], [[END]]
; CHECK-NEXT:    br i1 [[CMP]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv2 = phi i64 [ %iv2.next, %loop ], [ %base, %entry ]
  %iv = phi i64 [ %iv.next, %loop ], [ 0, %entry ]
  call void @use.i64(i64 %iv2)
  %iv.next = add nuw nsw i64 %iv, 4
  %iv2.next = add nuw i64 %iv.next, %base
  %cmp = icmp eq i64 %iv.next, %end
  br i1 %cmp, label %exit, label %loop

exit:
  ret void
}

define void @int_iv_nsw(i64 %base, i64 %end) {
; CHECK-LABEL: define void @int_iv_nsw(
; CHECK-SAME: i64 [[BASE:%.*]], i64 [[END:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[IV_NEXT:%.*]], [[LOOP]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[IV2:%.*]] = add nsw i64 [[IV]], [[BASE]]
; CHECK-NEXT:    call void @use.i64(i64 [[IV2]])
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i64 [[IV_NEXT]], [[END]]
; CHECK-NEXT:    br i1 [[CMP]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv2 = phi i64 [ %iv2.next, %loop ], [ %base, %entry ]
  %iv = phi i64 [ %iv.next, %loop ], [ 0, %entry ]
  call void @use.i64(i64 %iv2)
  %iv.next = add nuw nsw i64 %iv, 4
  %iv2.next = add nsw i64 %iv.next, %base
  %cmp = icmp eq i64 %iv.next, %end
  br i1 %cmp, label %exit, label %loop

exit:
  ret void
}

define void @int_iv_commuted_add(i64 %base, i64 %end) {
; CHECK-LABEL: define void @int_iv_commuted_add(
; CHECK-SAME: i64 [[BASE:%.*]], i64 [[END:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[BASE2:%.*]] = mul i64 [[BASE]], 42
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[IV_NEXT:%.*]], [[LOOP]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[IV2:%.*]] = add i64 [[IV]], [[BASE2]]
; CHECK-NEXT:    call void @use.i64(i64 [[IV2]])
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i64 [[IV_NEXT]], [[END]]
; CHECK-NEXT:    br i1 [[CMP]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  %base2 = mul i64 %base, 42 ; thwart complexity-based canonicalization
  br label %loop

loop:
  %iv2 = phi i64 [ %iv2.next, %loop ], [ %base2, %entry ]
  %iv = phi i64 [ %iv.next, %loop ], [ 0, %entry ]
  call void @use.i64(i64 %iv2)
  %iv.next = add nuw nsw i64 %iv, 4
  %iv2.next = add i64 %base2, %iv.next
  %cmp = icmp eq i64 %iv.next, %end
  br i1 %cmp, label %exit, label %loop

exit:
  ret void
}

define void @int_iv_commuted_phi1(i64 %base, i64 %end) {
; CHECK-LABEL: define void @int_iv_commuted_phi1(
; CHECK-SAME: i64 [[BASE:%.*]], i64 [[END:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[IV2:%.*]] = add i64 [[IV]], [[BASE]]
; CHECK-NEXT:    call void @use.i64(i64 [[IV2]])
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i64 [[IV_NEXT]], [[END]]
; CHECK-NEXT:    br i1 [[CMP]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv2 = phi i64 [ %base, %entry ], [ %iv2.next, %loop ]
  %iv = phi i64 [ %iv.next, %loop ], [ 0, %entry ]
  call void @use.i64(i64 %iv2)
  %iv.next = add nuw nsw i64 %iv, 4
  %iv2.next = add i64 %iv.next, %base
  %cmp = icmp eq i64 %iv.next, %end
  br i1 %cmp, label %exit, label %loop

exit:
  ret void
}

define void @int_iv_commuted_phi2(i64 %base, i64 %end) {
; CHECK-LABEL: define void @int_iv_commuted_phi2(
; CHECK-SAME: i64 [[BASE:%.*]], i64 [[END:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[IV_NEXT:%.*]], [[LOOP]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[IV2:%.*]] = add i64 [[IV]], [[BASE]]
; CHECK-NEXT:    call void @use.i64(i64 [[IV2]])
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i64 [[IV_NEXT]], [[END]]
; CHECK-NEXT:    br i1 [[CMP]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv2 = phi i64 [ %iv2.next, %loop ], [ %base, %entry ]
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %loop ]
  call void @use.i64(i64 %iv2)
  %iv.next = add nuw nsw i64 %iv, 4
  %iv2.next = add i64 %iv.next, %base
  %cmp = icmp eq i64 %iv.next, %end
  br i1 %cmp, label %exit, label %loop

exit:
  ret void
}

define void @int_iv_vector(<2 x i64> %base) {
; CHECK-LABEL: define void @int_iv_vector(
; CHECK-SAME: <2 x i64> [[BASE:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi <2 x i64> [ [[IV_NEXT:%.*]], [[LOOP]] ], [ zeroinitializer, [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[IV2:%.*]] = add <2 x i64> [[IV]], [[BASE]]
; CHECK-NEXT:    call void @use.v2i64(<2 x i64> [[IV2]])
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw <2 x i64> [[IV]], splat (i64 4)
; CHECK-NEXT:    [[CMP:%.*]] = call i1 @get.i1()
; CHECK-NEXT:    br i1 [[CMP]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv2 = phi <2 x i64> [ %iv2.next, %loop ], [ %base, %entry ]
  %iv = phi <2 x i64> [ %iv.next, %loop ], [ zeroinitializer, %entry ]
  call void @use.v2i64(<2 x i64> %iv2)
  %iv.next = add nuw nsw <2 x i64> %iv, <i64 4, i64 4>
  %iv2.next = add <2 x i64> %iv.next, %base
  %cmp = call i1 @get.i1()
  br i1 %cmp, label %exit, label %loop

exit:
  ret void
}

define void @int_iv_vector_poison_invalid(<2 x i64> %base) {
; CHECK-LABEL: define void @int_iv_vector_poison_invalid(
; CHECK-SAME: <2 x i64> [[BASE:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV2:%.*]] = phi <2 x i64> [ [[IV2_NEXT:%.*]], [[LOOP]] ], [ [[BASE]], [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[IV:%.*]] = phi <2 x i64> [ [[IV_NEXT:%.*]], [[LOOP]] ], [ <i64 0, i64 poison>, [[ENTRY]] ]
; CHECK-NEXT:    call void @use.v2i64(<2 x i64> [[IV2]])
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw <2 x i64> [[IV]], splat (i64 4)
; CHECK-NEXT:    [[IV2_NEXT]] = add <2 x i64> [[IV_NEXT]], [[BASE]]
; CHECK-NEXT:    [[CMP:%.*]] = call i1 @get.i1()
; CHECK-NEXT:    br i1 [[CMP]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv2 = phi <2 x i64> [ %iv2.next, %loop ], [ %base, %entry ]
  %iv = phi <2 x i64> [ %iv.next, %loop ], [ <i64 0, i64 poison>, %entry ]
  call void @use.v2i64(<2 x i64> %iv2)
  %iv.next = add nuw nsw <2 x i64> %iv, <i64 4, i64 4>
  %iv2.next = add <2 x i64> %iv.next, %base
  %cmp = call i1 @get.i1()
  br i1 %cmp, label %exit, label %loop

exit:
  ret void
}

define void @int_iv_loop_variant_step(i64 %base, i64 %end) {
; CHECK-LABEL: define void @int_iv_loop_variant_step(
; CHECK-SAME: i64 [[BASE:%.*]], i64 [[END:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[IV_NEXT:%.*]], [[LOOP]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[IV2:%.*]] = add nuw i64 [[IV]], [[BASE]]
; CHECK-NEXT:    call void @use.i64(i64 [[IV2]])
; CHECK-NEXT:    [[STEP:%.*]] = call i64 @get.i64()
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], [[STEP]]
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i64 [[IV_NEXT]], [[END]]
; CHECK-NEXT:    br i1 [[CMP]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv2 = phi i64 [ %iv2.next, %loop ], [ %base, %entry ]
  %iv = phi i64 [ %iv.next, %loop ], [ 0, %entry ]
  call void @use.i64(i64 %iv2)
  %step = call i64 @get.i64()
  %iv.next = add nuw nsw i64 %iv, %step
  %iv2.next = add nuw i64 %iv.next, %base
  %cmp = icmp eq i64 %iv.next, %end
  br i1 %cmp, label %exit, label %loop

exit:
  ret void
}

define void @int_iv_xor(i64 %base, i64 %end) {
; CHECK-LABEL: define void @int_iv_xor(
; CHECK-SAME: i64 [[BASE:%.*]], i64 [[END:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[IV_NEXT:%.*]], [[LOOP]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[IV2:%.*]] = xor i64 [[IV]], [[BASE]]
; CHECK-NEXT:    call void @use.i64(i64 [[IV2]])
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i64 [[IV_NEXT]], [[END]]
; CHECK-NEXT:    br i1 [[CMP]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv2 = phi i64 [ %iv2.next, %loop ], [ %base, %entry ]
  %iv = phi i64 [ %iv.next, %loop ], [ 0, %entry ]
  call void @use.i64(i64 %iv2)
  %iv.next = add nuw nsw i64 %iv, 4
  %iv2.next = xor i64 %iv.next, %base
  %cmp = icmp eq i64 %iv.next, %end
  br i1 %cmp, label %exit, label %loop

exit:
  ret void
}

define void @int_iv_or(i64 %base, i64 %end) {
; CHECK-LABEL: define void @int_iv_or(
; CHECK-SAME: i64 [[BASE:%.*]], i64 [[END:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[IV_NEXT:%.*]], [[LOOP]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[IV2:%.*]] = or i64 [[IV]], [[BASE]]
; CHECK-NEXT:    call void @use.i64(i64 [[IV2]])
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i64 [[IV_NEXT]], [[END]]
; CHECK-NEXT:    br i1 [[CMP]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv2 = phi i64 [ %iv2.next, %loop ], [ %base, %entry ]
  %iv = phi i64 [ %iv.next, %loop ], [ 0, %entry ]
  call void @use.i64(i64 %iv2)
  %iv.next = add nuw nsw i64 %iv, 4
  %iv2.next = or i64 %iv.next, %base
  %cmp = icmp eq i64 %iv.next, %end
  br i1 %cmp, label %exit, label %loop

exit:
  ret void
}

define void @int_iv_or_disjoint(i64 %base, i64 %end) {
; CHECK-LABEL: define void @int_iv_or_disjoint(
; CHECK-SAME: i64 [[BASE:%.*]], i64 [[END:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[IV_NEXT:%.*]], [[LOOP]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[IV2:%.*]] = or disjoint i64 [[IV]], [[BASE]]
; CHECK-NEXT:    call void @use.i64(i64 [[IV2]])
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i64 [[IV_NEXT]], [[END]]
; CHECK-NEXT:    br i1 [[CMP]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv2 = phi i64 [ %iv2.next, %loop ], [ %base, %entry ]
  %iv = phi i64 [ %iv.next, %loop ], [ 0, %entry ]
  call void @use.i64(i64 %iv2)
  %iv.next = add nuw nsw i64 %iv, 4
  %iv2.next = or disjoint i64 %iv.next, %base
  %cmp = icmp eq i64 %iv.next, %end
  br i1 %cmp, label %exit, label %loop

exit:
  ret void
}

define void @int_iv_and(i64 %base, i64 %end) {
; CHECK-LABEL: define void @int_iv_and(
; CHECK-SAME: i64 [[BASE:%.*]], i64 [[END:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[IV_NEXT:%.*]], [[LOOP]] ], [ -1, [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[IV2:%.*]] = and i64 [[IV]], [[BASE]]
; CHECK-NEXT:    call void @use.i64(i64 [[IV2]])
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i64 [[IV_NEXT]], [[END]]
; CHECK-NEXT:    br i1 [[CMP]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv2 = phi i64 [ %iv2.next, %loop ], [ %base, %entry ]
  %iv = phi i64 [ %iv.next, %loop ], [ -1, %entry ]
  call void @use.i64(i64 %iv2)
  %iv.next = add nuw nsw i64 %iv, 4
  %iv2.next = and i64 %iv.next, %base
  %cmp = icmp eq i64 %iv.next, %end
  br i1 %cmp, label %exit, label %loop

exit:
  ret void
}

define void @int_iv_sub(i64 %base, i64 %end) {
; CHECK-LABEL: define void @int_iv_sub(
; CHECK-SAME: i64 [[BASE:%.*]], i64 [[END:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV2:%.*]] = phi i64 [ [[IV2_NEXT:%.*]], [[LOOP]] ], [ [[BASE]], [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[IV_NEXT:%.*]], [[LOOP]] ], [ 0, [[ENTRY]] ]
; CHECK-NEXT:    call void @use.i64(i64 [[IV2]])
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 4
; CHECK-NEXT:    [[IV2_NEXT]] = sub i64 [[BASE]], [[IV_NEXT]]
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i64 [[IV_NEXT]], [[END]]
; CHECK-NEXT:    br i1 [[CMP]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv2 = phi i64 [ %iv2.next, %loop ], [ %base, %entry ]
  %iv = phi i64 [ %iv.next, %loop ], [ 0, %entry ]
  call void @use.i64(i64 %iv2)
  %iv.next = add nuw nsw i64 %iv, 4
  %iv2.next = sub i64 %base, %iv.next
  %cmp = icmp eq i64 %iv.next, %end
  br i1 %cmp, label %exit, label %loop

exit:
  ret void
}

define void @int_iv_sub_invalid_order(i64 %base, i64 %end) {
; CHECK-LABEL: define void @int_iv_sub_invalid_order(
; CHECK-SAME: i64 [[BASE:%.*]], i64 [[END:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV2:%.*]] = phi i64 [ [[IV2_NEXT:%.*]], [[LOOP]] ], [ [[BASE]], [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[IV_NEXT:%.*]], [[LOOP]] ], [ 0, [[ENTRY]] ]
; CHECK-NEXT:    call void @use.i64(i64 [[IV2]])
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 4
; CHECK-NEXT:    [[IV2_NEXT]] = sub i64 [[IV_NEXT]], [[BASE]]
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i64 [[IV_NEXT]], [[END]]
; CHECK-NEXT:    br i1 [[CMP]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv2 = phi i64 [ %iv2.next, %loop ], [ %base, %entry ]
  %iv = phi i64 [ %iv.next, %loop ], [ 0, %entry ]
  call void @use.i64(i64 %iv2)
  %iv.next = add nuw nsw i64 %iv, 4
  %iv2.next = sub i64 %iv.next, %base
  %cmp = icmp eq i64 %iv.next, %end
  br i1 %cmp, label %exit, label %loop

exit:
  ret void
}

define void @int_iv_add_wrong_start(i64 %base, i64 %end) {
; CHECK-LABEL: define void @int_iv_add_wrong_start(
; CHECK-SAME: i64 [[BASE:%.*]], i64 [[END:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV2:%.*]] = phi i64 [ [[IV2_NEXT:%.*]], [[LOOP]] ], [ [[BASE]], [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[IV_NEXT:%.*]], [[LOOP]] ], [ 1, [[ENTRY]] ]
; CHECK-NEXT:    call void @use.i64(i64 [[IV2]])
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 4
; CHECK-NEXT:    [[IV2_NEXT]] = add i64 [[BASE]], [[IV_NEXT]]
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i64 [[IV_NEXT]], [[END]]
; CHECK-NEXT:    br i1 [[CMP]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv2 = phi i64 [ %iv2.next, %loop ], [ %base, %entry ]
  %iv = phi i64 [ %iv.next, %loop ], [ 1, %entry ]
  call void @use.i64(i64 %iv2)
  %iv.next = add nuw nsw i64 %iv, 4
  %iv2.next = add i64 %base, %iv.next
  %cmp = icmp eq i64 %iv.next, %end
  br i1 %cmp, label %exit, label %loop

exit:
  ret void
}

define void @int_iv_and_wrong_start(i64 %base, i64 %end) {
; CHECK-LABEL: define void @int_iv_and_wrong_start(
; CHECK-SAME: i64 [[BASE:%.*]], i64 [[END:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV2:%.*]] = phi i64 [ [[IV2_NEXT:%.*]], [[LOOP]] ], [ [[BASE]], [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[IV_NEXT:%.*]], [[LOOP]] ], [ 0, [[ENTRY]] ]
; CHECK-NEXT:    call void @use.i64(i64 [[IV2]])
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 4
; CHECK-NEXT:    [[IV2_NEXT]] = and i64 [[IV_NEXT]], [[BASE]]
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i64 [[IV_NEXT]], [[END]]
; CHECK-NEXT:    br i1 [[CMP]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv2 = phi i64 [ %iv2.next, %loop ], [ %base, %entry ]
  %iv = phi i64 [ %iv.next, %loop ], [ 0, %entry ]
  call void @use.i64(i64 %iv2)
  %iv.next = add nuw nsw i64 %iv, 4
  %iv2.next = and i64 %iv.next, %base
  %cmp = icmp eq i64 %iv.next, %end
  br i1 %cmp, label %exit, label %loop

exit:
  ret void
}

define void @ptr_iv_inbounds(ptr %base, i64 %end) {
; CHECK-LABEL: define void @ptr_iv_inbounds(
; CHECK-SAME: ptr [[BASE:%.*]], i64 [[END:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[IV_NEXT:%.*]], [[LOOP]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[IV_PTR:%.*]] = getelementptr inbounds i8, ptr [[BASE]], i64 [[IV]]
; CHECK-NEXT:    call void @use.p0(ptr [[IV_PTR]])
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i64 [[IV_NEXT]], [[END]]
; CHECK-NEXT:    br i1 [[CMP]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv.ptr = phi ptr [ %iv.ptr.next, %loop ], [ %base, %entry ]
  %iv = phi i64 [ %iv.next, %loop ], [ 0, %entry ]
  call void @use.p0(ptr %iv.ptr)
  %iv.next = add nuw nsw i64 %iv, 4
  %iv.ptr.next = getelementptr inbounds i8, ptr %base, i64 %iv.next
  %cmp = icmp eq i64 %iv.next, %end
  br i1 %cmp, label %exit, label %loop

exit:
  ret void
}

define void @ptr_iv_nuw(ptr %base, i64 %end) {
; CHECK-LABEL: define void @ptr_iv_nuw(
; CHECK-SAME: ptr [[BASE:%.*]], i64 [[END:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[IV_NEXT:%.*]], [[LOOP]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[IV_PTR:%.*]] = getelementptr nuw i8, ptr [[BASE]], i64 [[IV]]
; CHECK-NEXT:    call void @use.p0(ptr [[IV_PTR]])
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i64 [[IV_NEXT]], [[END]]
; CHECK-NEXT:    br i1 [[CMP]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv.ptr = phi ptr [ %iv.ptr.next, %loop ], [ %base, %entry ]
  %iv = phi i64 [ %iv.next, %loop ], [ 0, %entry ]
  call void @use.p0(ptr %iv.ptr)
  %iv.next = add nuw nsw i64 %iv, 4
  %iv.ptr.next = getelementptr nuw i8, ptr %base, i64 %iv.next
  %cmp = icmp eq i64 %iv.next, %end
  br i1 %cmp, label %exit, label %loop

exit:
  ret void
}

define void @ptr_iv_no_flags(ptr %base, i64 %end) {
; CHECK-LABEL: define void @ptr_iv_no_flags(
; CHECK-SAME: ptr [[BASE:%.*]], i64 [[END:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[IV_NEXT:%.*]], [[LOOP]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[IV_PTR:%.*]] = getelementptr i8, ptr [[BASE]], i64 [[IV]]
; CHECK-NEXT:    call void @use.p0(ptr [[IV_PTR]])
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i64 [[IV_NEXT]], [[END]]
; CHECK-NEXT:    br i1 [[CMP]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv.ptr = phi ptr [ %iv.ptr.next, %loop ], [ %base, %entry ]
  %iv = phi i64 [ %iv.next, %loop ], [ 0, %entry ]
  call void @use.p0(ptr %iv.ptr)
  %iv.next = add nuw nsw i64 %iv, 4
  %iv.ptr.next = getelementptr i8, ptr %base, i64 %iv.next
  %cmp = icmp eq i64 %iv.next, %end
  br i1 %cmp, label %exit, label %loop

exit:
  ret void
}

define void @ptr_iv_non_i8_type(ptr %base, i64 %end) {
; CHECK-LABEL: define void @ptr_iv_non_i8_type(
; CHECK-SAME: ptr [[BASE:%.*]], i64 [[END:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[IV_NEXT:%.*]], [[LOOP]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[IV_PTR:%.*]] = getelementptr i32, ptr [[BASE]], i64 [[IV]]
; CHECK-NEXT:    call void @use.p0(ptr [[IV_PTR]])
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i64 [[IV_NEXT]], [[END]]
; CHECK-NEXT:    br i1 [[CMP]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv.ptr = phi ptr [ %iv.ptr.next, %loop ], [ %base, %entry ]
  %iv = phi i64 [ %iv.next, %loop ], [ 0, %entry ]
  call void @use.p0(ptr %iv.ptr)
  %iv.next = add nuw nsw i64 %iv, 4
  %iv.ptr.next = getelementptr i32, ptr %base, i64 %iv.next
  %cmp = icmp eq i64 %iv.next, %end
  br i1 %cmp, label %exit, label %loop

exit:
  ret void
}

define void @ptr_iv_vector(<2 x ptr> %base, i64 %end) {
; CHECK-LABEL: define void @ptr_iv_vector(
; CHECK-SAME: <2 x ptr> [[BASE:%.*]], i64 [[END:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[IV_NEXT:%.*]], [[LOOP]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[IV_PTR:%.*]] = getelementptr inbounds i8, <2 x ptr> [[BASE]], i64 [[IV]]
; CHECK-NEXT:    call void @use.v2p0(<2 x ptr> [[IV_PTR]])
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i64 [[IV_NEXT]], [[END]]
; CHECK-NEXT:    br i1 [[CMP]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv.ptr = phi <2 x ptr> [ %iv.ptr.next, %loop ], [ %base, %entry ]
  %iv = phi i64 [ %iv.next, %loop ], [ 0, %entry ]
  call void @use.v2p0(<2 x ptr> %iv.ptr)
  %iv.next = add nuw nsw i64 %iv, 4
  %iv.ptr.next = getelementptr inbounds i8, <2 x ptr> %base, i64 %iv.next
  %cmp = icmp eq i64 %iv.next, %end
  br i1 %cmp, label %exit, label %loop

exit:
  ret void
}

define void @ptr_iv_vector2(<2 x ptr> %base) {
; CHECK-LABEL: define void @ptr_iv_vector2(
; CHECK-SAME: <2 x ptr> [[BASE:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi <2 x i64> [ [[IV_NEXT:%.*]], [[LOOP]] ], [ zeroinitializer, [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[IV_PTR:%.*]] = getelementptr i8, <2 x ptr> [[BASE]], <2 x i64> [[IV]]
; CHECK-NEXT:    call void @use.v2p0(<2 x ptr> [[IV_PTR]])
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw <2 x i64> [[IV]], splat (i64 4)
; CHECK-NEXT:    [[CMP:%.*]] = call i1 @get.i1()
; CHECK-NEXT:    br i1 [[CMP]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv.ptr = phi <2 x ptr> [ %iv.ptr.next, %loop ], [ %base, %entry ]
  %iv = phi <2 x i64> [ %iv.next, %loop ], [ zeroinitializer, %entry ]
  call void @use.v2p0(<2 x ptr> %iv.ptr)
  %iv.next = add nuw nsw <2 x i64> %iv, <i64 4, i64 4>
  %iv.ptr.next = getelementptr i8, <2 x ptr> %base, <2 x i64> %iv.next
  %cmp = call i1 @get.i1()
  br i1 %cmp, label %exit, label %loop

exit:
  ret void
}

define void @different_loops(i64 %base) {
; CHECK-LABEL: define void @different_loops(
; CHECK-SAME: i64 [[BASE:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP1:%.*]]
; CHECK:       loop1:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[IV_NEXT:%.*]], [[LOOP1]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    call void @use.i64(i64 [[IV]])
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 4
; CHECK-NEXT:    [[CMP:%.*]] = call i1 @get.i1()
; CHECK-NEXT:    br i1 [[CMP]], label [[LOOP2:%.*]], label [[LOOP1]]
; CHECK:       loop2:
; CHECK-NEXT:    [[IV2:%.*]] = phi i64 [ [[IV2_NEXT:%.*]], [[LOOP2]] ], [ [[BASE]], [[LOOP1]] ]
; CHECK-NEXT:    call void @use.i64(i64 [[IV2]])
; CHECK-NEXT:    [[IV2_NEXT]] = add nuw i64 [[BASE]], [[IV_NEXT]]
; CHECK-NEXT:    [[CMP2:%.*]] = call i1 @get.i1()
; CHECK-NEXT:    br i1 [[CMP2]], label [[EXIT:%.*]], label [[LOOP2]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop1

loop1:
  %iv = phi i64 [ %iv.next, %loop1 ], [ 0, %entry ]
  call void @use.i64(i64 %iv)
  %iv.next = add nuw nsw i64 %iv, 4
  %cmp = call i1 @get.i1()
  br i1 %cmp, label %loop2, label %loop1

loop2:
  %iv2 = phi i64 [ %iv2.next, %loop2 ], [ %base, %loop1 ]
  call void @use.i64(i64 %iv2)
  %iv2.next = add nuw i64 %base, %iv.next
  %cmp2 = call i1 @get.i1()
  br i1 %cmp2, label %exit, label %loop2

exit:
  ret void
}

declare void @use.p0(ptr)
declare void @use.v2p0(<2 x ptr>)
declare void @use.i64(i64)
declare void @use.v2i64(<2 x i64>)
declare i1 @get.i1()
declare i64 @get.i64()
