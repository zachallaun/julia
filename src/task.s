	.def	 restore_stack;
	.scl	2;
	.type	32;
	.endef
	.text
	.globl	restore_stack
	.align	16, 0x90
restore_stack:
	.cfi_startproc
	pushq	%rbp
.Ltmp2:
	.cfi_def_cfa_offset 16
.Ltmp3:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
.Ltmp4:
	.cfi_def_cfa_register %rbp
	subq	$16, %rsp
	movq	%r8, %rax
	movq	320(%rcx), %r8
	subq	608(%rcx), %r8
	movq	%r8, -8(%rbp)
	testq	%rax, %rax
	jne	.LBB0_4
	leaq	-8(%rbp), %rax
	subq	%r8, %rax
	jbe	.LBB0_3
	addq	$15, %rax
	andq	$-16, %rax
	callq	___chkstk
	movq	%rsp, %r8
.LBB0_3:
	subq	$32, %rsp
	callq	restore_stack
	addq	$32, %rsp
.LBB0_4:
	movq	%rdx, jl_jmp_target(%rip)
	movq	600(%rcx), %rdx
	testq	%rdx, %rdx
	je	.LBB0_6
	movq	608(%rcx), %r8
	movq	-8(%rbp), %rcx
	subq	$32, %rsp
	callq	memcpy
	addq	$32, %rsp
.LBB0_6:
	movq	jl_jmp_target(%rip), %rax
	movq	(%rax), %rbp
	movq	8(%rax), %rcx
	movq	16(%rax), %rsp
	jmpq	*%rcx
	.cfi_endproc

	.def	 jl_switch_stack;
	.scl	2;
	.type	32;
	.endef
	.globl	jl_switch_stack
	.align	16, 0x90
jl_switch_stack:
	.cfi_startproc
	jmp	switch_stack
	.cfi_endproc

	.def	 switch_stack;
	.scl	3;
	.type	32;
	.endef
	.align	16, 0x90
switch_stack:
	.cfi_startproc
	pushq	%rbp
.Ltmp8:
	.cfi_def_cfa_offset 16
.Ltmp9:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
.Ltmp10:
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rsi
	pushq	%rdi
	pushq	%rbx
	subq	$248, %rsp
.Ltmp11:
	.cfi_offset %rbx, -240
.Ltmp12:
	.cfi_offset %rdi, -232
.Ltmp13:
	.cfi_offset %rsi, -224
.Ltmp14:
	.cfi_offset %r12, -216
.Ltmp15:
	.cfi_offset %r13, -208
.Ltmp16:
	.cfi_offset %r14, -200
.Ltmp17:
	.cfi_offset %r15, -192
.Ltmp18:
	.cfi_offset %xmm6, -168
.Ltmp19:
	.cfi_offset %xmm7, -152
.Ltmp20:
	.cfi_offset %xmm8, -136
.Ltmp21:
	.cfi_offset %xmm9, -120
.Ltmp22:
	.cfi_offset %xmm10, -104
.Ltmp23:
	.cfi_offset %xmm11, -88
.Ltmp24:
	.cfi_offset %xmm12, -72
.Ltmp25:
	.cfi_offset %xmm13, -56
.Ltmp26:
	.cfi_offset %xmm14, -40
.Ltmp27:
	.cfi_offset %xmm15, -24
	movaps	%xmm15, -224(%rbp)
	movaps	%xmm14, -208(%rbp)
	movaps	%xmm13, -192(%rbp)
	movaps	%xmm12, -176(%rbp)
	movaps	%xmm11, -160(%rbp)
	movaps	%xmm10, -144(%rbp)
	movaps	%xmm9, -128(%rbp)
	movaps	%xmm8, -112(%rbp)
	movaps	%xmm7, -96(%rbp)
	movaps	%xmm6, -80(%rbp)
	cmpq	$0, 600(%rcx)
	jne	.LBB2_15
	movq	jl_task_arg_in_transit(%rip), %rax
	movq	%rax, -232(%rbp)
	movq	$3, -256(%rbp)
	movq	jl_pgcstack(%rip), %rax
	movq	%rax, -248(%rbp)
	leaq	-256(%rbp), %rax
	leaq	-232(%rbp), %rdx
	movq	%rdx, -240(%rbp)
	movq	%rax, jl_pgcstack(%rip)
	movq	_frame_offset(%rip), %rax
	leaq	-144(%rbp,%rax), %rax
	movq	%rax, 320(%rcx)
	movq	%rbp, 336(%rcx)
	movq	%rsp, 352(%rcx)
	movq	$.LBB2_16, 344(%rcx)
	movq	%rcx, -264(%rbp)
	#EH_SjLj_Setup	.LBB2_16
	xorl	%eax, %eax
	jmp	.LBB2_3
.LBB2_16:
	movl	$1, %eax
.LBB2_3:
	testl	%eax, %eax
	movq	-264(%rbp), %rsi
	je	.LBB2_5
	movq	jl_current_task(%rip), %rcx
	movq	jl_jmp_target(%rip), %rdx
	callq	switch_stack
.LBB2_5:
	cmpl	$0, n_args_in_transit(%rip)
	je	.LBB2_6
	movl	n_args_in_transit(%rip), %eax
	movq	616(%rsi), %rcx
	cmpl	$1, %eax
	jne	.LBB2_9
	leaq	-232(%rbp), %rdx
	movl	$1, %r8d
	jmp	.LBB2_10
.LBB2_6:
	movq	616(%rsi), %rcx
	xorl	%edx, %edx
	xorl	%r8d, %r8d
	jmp	.LBB2_10
.LBB2_9:
	movq	jl_task_arg_in_transit(%rip), %rdx
	movl	n_args_in_transit(%rip), %r8d
	addq	$16, %rdx
.LBB2_10:
	callq	*8(%rcx)
	movq	jl_pgcstack(%rip), %rcx
	movq	8(%rcx), %rcx
	movq	%rcx, jl_pgcstack(%rip)
	movb	$1, 40(%rsi)
	movq	%rax, 48(%rsi)
	movq	$0, 600(%rsi)
	.align	16, 0x90
.LBB2_11:
	movq	8(%rsi), %rsi
	cmpb	$0, 40(%rsi)
	jne	.LBB2_11
	movq	%rax, jl_task_arg_in_transit(%rip)
	movl	$1, n_args_in_transit(%rip)
	cmpb	$0, 40(%rsi)
	jne	.LBB2_14
	movq	%rsi, %rcx
	leaq	64(%rsi), %rdx
	callq	ctx_switch
	movq	jl_task_arg_in_transit(%rip), %rax
.LBB2_14:
	movq	jl_null(%rip), %rax
	movq	%rax, jl_task_arg_in_transit(%rip)
	movaps	-80(%rbp), %xmm6
	movaps	-96(%rbp), %xmm7
	movaps	-112(%rbp), %xmm8
	movaps	-128(%rbp), %xmm9
	movaps	-144(%rbp), %xmm10
	movaps	-160(%rbp), %xmm11
	movaps	-176(%rbp), %xmm12
	movaps	-192(%rbp), %xmm13
	movaps	-208(%rbp), %xmm14
	movaps	-224(%rbp), %xmm15
	addq	$248, %rsp
	popq	%rbx
	popq	%rdi
	popq	%rsi
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	ret
.LBB2_15:
	xorl	%r8d, %r8d
	callq	restore_stack
	.cfi_endproc

	.def	 jl_switchto;
	.scl	2;
	.type	32;
	.endef
	.globl	jl_switchto
	.align	16, 0x90
jl_switchto:
	.cfi_startproc
	pushq	%rbp
.Ltmp30:
	.cfi_def_cfa_offset 16
.Ltmp31:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
.Ltmp32:
	.cfi_def_cfa_register %rbp
	subq	$32, %rsp
	movq	%rdx, jl_task_arg_in_transit(%rip)
	movl	$1, n_args_in_transit(%rip)
	cmpb	$0, 40(%rcx)
	je	.LBB3_2
	movq	jl_null(%rip), %rax
	movq	%rax, jl_task_arg_in_transit(%rip)
	movq	48(%rcx), %rax
	jmp	.LBB3_3
.LBB3_2:
	leaq	64(%rcx), %rdx
	callq	ctx_switch
	movq	jl_task_arg_in_transit(%rip), %rax
	movq	jl_null(%rip), %rcx
	movq	%rcx, jl_task_arg_in_transit(%rip)
.LBB3_3:
	addq	$32, %rsp
	popq	%rbp
	ret
	.cfi_endproc

	.def	 jl_parse_backtrace;
	.scl	2;
	.type	32;
	.endef
	.globl	jl_parse_backtrace
	.align	16, 0x90
jl_parse_backtrace:
	.cfi_startproc
	pushq	%rbp
.Ltmp36:
	.cfi_def_cfa_offset 16
.Ltmp37:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
.Ltmp38:
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rsi
	pushq	%rdi
	pushq	%rbx
	subq	$88, %rsp
.Ltmp39:
	.cfi_offset %rbx, -72
.Ltmp40:
	.cfi_offset %rdi, -64
.Ltmp41:
	.cfi_offset %rsi, -56
.Ltmp42:
	.cfi_offset %r12, -48
.Ltmp43:
	.cfi_offset %r13, -40
.Ltmp44:
	.cfi_offset %r14, -32
.Ltmp45:
	.cfi_offset %r15, -24
	movl	%r8d, %edi
	movq	%rdx, %rsi
	movq	%rcx, %r13
	xorl	%ecx, %ecx
	callq	jl_alloc_cell_1d
	movq	%rax, %rbx
	movq	%rbx, -88(%rbp)
	movq	$3, -112(%rbp)
	movq	jl_pgcstack(%rip), %rax
	movq	%rax, -104(%rbp)
	leaq	-88(%rbp), %rax
	movq	%rax, -96(%rbp)
	leaq	-112(%rbp), %rax
	movq	%rax, jl_pgcstack(%rip)
	testq	%rsi, %rsi
	je	.LBB4_15
	movabsq	$4294967296, %r15
	testl	%edi, %edi
	jne	.LBB4_7
	movabsq	$8589934592, %r12
	jmp	.LBB4_3
	.align	16, 0x90
.LBB4_13:
	addq	$8, %r13
	movq	-88(%rbp), %rbx
.LBB4_7:
	movq	(%r13), %r9
	movq	16(%rbx), %rdi
	leaq	-64(%rbp), %rcx
	leaq	-68(%rbp), %rdx
	leaq	-80(%rbp), %r8
	callq	getFunctionInfo
	movb	$1, %r12b
	cmpq	$0, -64(%rbp)
	jne	.LBB4_9
	movq	$.L.str12, -64(%rbp)
	movq	$.L.str12, -80(%rbp)
	movl	$0, -68(%rbp)
	xorb	%r12b, %r12b
.LBB4_9:
	movq	%rbx, %rcx
	movl	$3, %edx
	callq	jl_array_grow_end
	movq	-64(%rbp), %rcx
	callq	jl_symbol
	movslq	%edi, %r14
	movq	%rbx, %rcx
	movq	%rax, %rdx
	movq	%r14, %r8
	callq	jl_arrayset
	shlq	$32, %rdi
	addq	%r15, %rdi
	movq	-80(%rbp), %rcx
	callq	jl_symbol
	sarq	$32, %rdi
	movq	%rbx, %rcx
	movq	%rax, %rdx
	movq	%rdi, %r8
	callq	jl_arrayset
	addl	$2, %r14d
	testb	%r12b, %r12b
	movslq	-68(%rbp), %rcx
	je	.LBB4_10
	callq	jl_box_int64
	jmp	.LBB4_12
	.align	16, 0x90
.LBB4_10:
	callq	jl_box_uint64
.LBB4_12:
	movslq	%r14d, %r8
	movq	%rbx, %rcx
	movq	%rax, %rdx
	callq	jl_arrayset
	decq	%rsi
	je	.LBB4_14
	jmp	.LBB4_13
	.align	16, 0x90
.LBB4_6:
	addq	$8, %r13
	movq	-88(%rbp), %rbx
.LBB4_3:
	movq	(%r13), %r9
	movq	16(%rbx), %rdi
	leaq	-64(%rbp), %rcx
	leaq	-68(%rbp), %rdx
	leaq	-80(%rbp), %r8
	callq	getFunctionInfo
	cmpq	$0, -64(%rbp)
	je	.LBB4_5
	movq	%rbx, %rcx
	movl	$3, %edx
	callq	jl_array_grow_end
	movq	-64(%rbp), %rcx
	callq	jl_symbol
	movslq	%edi, %r8
	movq	%rbx, %rcx
	movq	%rax, %rdx
	callq	jl_arrayset
	shlq	$32, %rdi
	leaq	(%rdi,%r15), %r14
	movq	-80(%rbp), %rcx
	callq	jl_symbol
	sarq	$32, %r14
	movq	%rbx, %rcx
	movq	%rax, %rdx
	movq	%r14, %r8
	callq	jl_arrayset
	addq	%r12, %rdi
	movslq	-68(%rbp), %rcx
	callq	jl_box_int64
	sarq	$32, %rdi
	movq	%rbx, %rcx
	movq	%rax, %rdx
	movq	%rdi, %r8
	callq	jl_arrayset
.LBB4_5:
	decq	%rsi
	jne	.LBB4_6
.LBB4_14:
	movq	-88(%rbp), %rbx
	movq	jl_pgcstack(%rip), %rax
.LBB4_15:
	movq	8(%rax), %rax
	movq	%rax, jl_pgcstack(%rip)
	movq	%rbx, %rax
	addq	$88, %rsp
	popq	%rbx
	popq	%rdi
	popq	%rsi
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	ret
	.cfi_endproc

	.def	 jl_get_backtrace;
	.scl	2;
	.type	32;
	.endef
	.globl	jl_get_backtrace
	.align	16, 0x90
jl_get_backtrace:
	.cfi_startproc
	movq	bt_size(%rip), %rdx
	movl	$bt_data, %ecx
	xorl	%r8d, %r8d
	jmp	jl_parse_backtrace
	.cfi_endproc

	.def	 rec_backtrace;
	.scl	2;
	.type	32;
	.endef
	.globl	rec_backtrace
	.align	16, 0x90
rec_backtrace:
	.cfi_startproc
	pushq	%rbp
.Ltmp48:
	.cfi_def_cfa_offset 16
.Ltmp49:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
.Ltmp50:
	.cfi_def_cfa_register %rbp
	subq	$32, %rsp
	movq	%rcx, %rax
	xorl	%ecx, %ecx
	movq	%rax, %r8
	xorl	%r9d, %r9d
	callq	*__imp_RtlCaptureStackBackTrace
	movzwl	%ax, %eax
	addq	$32, %rsp
	popq	%rbp
	ret
	.cfi_endproc

	.def	 gdblookup;
	.scl	2;
	.type	32;
	.endef
	.globl	gdblookup
	.align	16, 0x90
gdblookup:
	.cfi_startproc
	pushq	%rbp
.Ltmp53:
	.cfi_def_cfa_offset 16
.Ltmp54:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
.Ltmp55:
	.cfi_def_cfa_register %rbp
	subq	$64, %rsp
	movq	%rcx, %rax
	leaq	-8(%rbp), %rcx
	leaq	-12(%rbp), %rdx
	leaq	-24(%rbp), %r8
	movq	%rax, %r9
	callq	getFunctionInfo
	movq	-8(%rbp), %r8
	testq	%r8, %r8
	je	.LBB7_1
	movq	-24(%rbp), %r9
	movq	ios_stderr(%rip), %rcx
	movl	-12(%rbp), %eax
	movl	%eax, 32(%rsp)
	movl	$.L.str1, %edx
	jmp	.LBB7_3
.LBB7_1:
	movq	$.L.str12, -8(%rbp)
	movq	$.L.str12, -24(%rbp)
	movl	$0, -12(%rbp)
	movq	ios_stderr(%rip), %rcx
	movl	$0, 32(%rsp)
	movl	$.L.str, %edx
	movl	$.L.str12, %r8d
	movl	$.L.str12, %r9d
.LBB7_3:
	callq	ios_printf
	addq	$64, %rsp
	popq	%rbp
	ret
	.cfi_endproc

	.def	 gdbbacktrace;
	.scl	2;
	.type	32;
	.endef
	.globl	gdbbacktrace
	.align	16, 0x90
gdbbacktrace:
	.cfi_startproc
	pushq	%rbp
.Ltmp59:
	.cfi_def_cfa_offset 16
.Ltmp60:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
.Ltmp61:
	.cfi_def_cfa_register %rbp
	pushq	%r14
	pushq	%rsi
	pushq	%rdi
	pushq	%rbx
	subq	$64, %rsp
.Ltmp62:
	.cfi_offset %rbx, -48
.Ltmp63:
	.cfi_offset %rdi, -40
.Ltmp64:
	.cfi_offset %rsi, -32
.Ltmp65:
	.cfi_offset %r14, -24
	xorl	%esi, %esi
	xorl	%ecx, %ecx
	movl	$80000, %edx
	movl	$bt_data, %r8d
	xorl	%r9d, %r9d
	callq	*__imp_RtlCaptureStackBackTrace
	movzwl	%ax, %eax
	movq	%rax, bt_size(%rip)
	testw	%ax, %ax
	je	.LBB8_6
	leaq	-40(%rbp), %r14
	leaq	-44(%rbp), %rdi
	leaq	-56(%rbp), %rbx
	.align	16, 0x90
.LBB8_2:
	movq	bt_data(,%rsi,8), %r9
	movq	%r14, %rcx
	movq	%rdi, %rdx
	movq	%rbx, %r8
	callq	getFunctionInfo
	movq	-40(%rbp), %r8
	testq	%r8, %r8
	jne	.LBB8_4
	movq	$.L.str12, -40(%rbp)
	movq	$.L.str12, -56(%rbp)
	movl	$0, -44(%rbp)
	movq	ios_stderr(%rip), %rcx
	movl	$0, 32(%rsp)
	movl	$.L.str, %edx
	movl	$.L.str12, %r8d
	movl	$.L.str12, %r9d
	jmp	.LBB8_5
	.align	16, 0x90
.LBB8_4:
	movq	-56(%rbp), %r9
	movq	ios_stderr(%rip), %rcx
	movl	-44(%rbp), %eax
	movl	%eax, 32(%rsp)
	movl	$.L.str1, %edx
.LBB8_5:
	callq	ios_printf
	incq	%rsi
	cmpq	bt_size(%rip), %rsi
	jb	.LBB8_2
.LBB8_6:
	addq	$64, %rsp
	popq	%rbx
	popq	%rdi
	popq	%rsi
	popq	%r14
	popq	%rbp
	ret
	.cfi_endproc

	.def	 jlbacktrace;
	.scl	2;
	.type	32;
	.endef
	.globl	jlbacktrace
	.align	16, 0x90
jlbacktrace:
	.cfi_startproc
	pushq	%rbp
.Ltmp69:
	.cfi_def_cfa_offset 16
.Ltmp70:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
.Ltmp71:
	.cfi_def_cfa_register %rbp
	pushq	%r14
	pushq	%rsi
	pushq	%rdi
	pushq	%rbx
	subq	$64, %rsp
.Ltmp72:
	.cfi_offset %rbx, -48
.Ltmp73:
	.cfi_offset %rdi, -40
.Ltmp74:
	.cfi_offset %rsi, -32
.Ltmp75:
	.cfi_offset %r14, -24
	cmpq	$0, bt_size(%rip)
	je	.LBB9_6
	xorl	%esi, %esi
	leaq	-40(%rbp), %r14
	leaq	-44(%rbp), %rdi
	leaq	-56(%rbp), %rbx
	.align	16, 0x90
.LBB9_2:
	movq	bt_data(,%rsi,8), %r9
	movq	%r14, %rcx
	movq	%rdi, %rdx
	movq	%rbx, %r8
	callq	getFunctionInfo
	movq	-40(%rbp), %r8
	testq	%r8, %r8
	jne	.LBB9_4
	movq	$.L.str12, -40(%rbp)
	movq	$.L.str12, -56(%rbp)
	movl	$0, -44(%rbp)
	movq	ios_stderr(%rip), %rcx
	movl	$0, 32(%rsp)
	movl	$.L.str, %edx
	movl	$.L.str12, %r8d
	movl	$.L.str12, %r9d
	jmp	.LBB9_5
	.align	16, 0x90
.LBB9_4:
	movq	-56(%rbp), %r9
	movq	ios_stderr(%rip), %rcx
	movl	-44(%rbp), %eax
	movl	%eax, 32(%rsp)
	movl	$.L.str1, %edx
.LBB9_5:
	callq	ios_printf
	incq	%rsi
	cmpq	bt_size(%rip), %rsi
	jb	.LBB9_2
.LBB9_6:
	addq	$64, %rsp
	popq	%rbx
	popq	%rdi
	popq	%rsi
	popq	%r14
	popq	%rbp
	ret
	.cfi_endproc

	.def	 jl_throw;
	.scl	2;
	.type	32;
	.endef
	.globl	jl_throw
	.align	16, 0x90
jl_throw:
	.cfi_startproc
	pushq	%rbp
.Ltmp79:
	.cfi_def_cfa_offset 16
.Ltmp80:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
.Ltmp81:
	.cfi_def_cfa_register %rbp
	pushq	%rsi
	subq	$40, %rsp
.Ltmp82:
	.cfi_offset %rsi, -24
	movq	%rcx, %rsi
	xorl	%ecx, %ecx
	movl	$80000, %edx
	movl	$bt_data, %r8d
	xorl	%r9d, %r9d
	callq	*__imp_RtlCaptureStackBackTrace
	movzwl	%ax, %eax
	movq	%rax, bt_size(%rip)
	movq	%rsi, %rcx
	callq	throw_internal
	.cfi_endproc

	.def	 throw_internal;
	.scl	3;
	.type	32;
	.endef
	.align	16, 0x90
throw_internal:
	.cfi_startproc
	pushq	%rbp
.Ltmp85:
	.cfi_def_cfa_offset 16
.Ltmp86:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
.Ltmp87:
	.cfi_def_cfa_register %rbp
	subq	$32, %rsp
	movq	%rcx, %rax
	movq	%rax, jl_exception_in_transit(%rip)
	movq	jl_current_task(%rip), %rcx
	cmpq	$0, 624(%rcx)
	movq	jl_current_task(%rip), %rcx
	jne	.LBB11_3
	.align	16, 0x90
.LBB11_1:
	movq	8(%rcx), %rcx
	cmpb	$0, 40(%rcx)
	jne	.LBB11_1
	movq	jl_current_task(%rip), %rdx
	movb	$1, 40(%rdx)
	movq	%rax, 48(%rdx)
	movq	$0, 600(%rdx)
	movq	624(%rcx), %rdx
	callq	ctx_switch
	movl	$1, %ecx
	callq	jl_exit
.LBB11_3:
	movq	624(%rcx), %rax
	movq	(%rax), %rbp
	movq	8(%rax), %rcx
	movq	16(%rax), %rsp
	jmpq	*%rcx
	.cfi_endproc

	.def	 jl_rethrow;
	.scl	2;
	.type	32;
	.endef
	.globl	jl_rethrow
	.align	16, 0x90
jl_rethrow:
	.cfi_startproc
	pushq	%rbp
.Ltmp90:
	.cfi_def_cfa_offset 16
.Ltmp91:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
.Ltmp92:
	.cfi_def_cfa_register %rbp
	subq	$32, %rsp
	movq	jl_exception_in_transit(%rip), %rcx
	callq	throw_internal
	.cfi_endproc

	.def	 jl_rethrow_other;
	.scl	2;
	.type	32;
	.endef
	.globl	jl_rethrow_other
	.align	16, 0x90
jl_rethrow_other:
	.cfi_startproc
	pushq	%rbp
.Ltmp95:
	.cfi_def_cfa_offset 16
.Ltmp96:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
.Ltmp97:
	.cfi_def_cfa_register %rbp
	subq	$32, %rsp
	callq	throw_internal
	.cfi_endproc

	.def	 jl_throw_with_superfluous_argument;
	.scl	2;
	.type	32;
	.endef
	.globl	jl_throw_with_superfluous_argument
	.align	16, 0x90
jl_throw_with_superfluous_argument:
	.cfi_startproc
	pushq	%rbp
.Ltmp100:
	.cfi_def_cfa_offset 16
.Ltmp101:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
.Ltmp102:
	.cfi_def_cfa_register %rbp
	subq	$32, %rsp
	callq	jl_throw
	.cfi_endproc

	.def	 jl_new_task;
	.scl	2;
	.type	32;
	.endef
	.globl	jl_new_task
	.align	16, 0x90
jl_new_task:
	.cfi_startproc
	pushq	%rbp
.Ltmp106:
	.cfi_def_cfa_offset 16
.Ltmp107:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
.Ltmp108:
	.cfi_def_cfa_register %rbp
	pushq	%rsi
	pushq	%rdi
	pushq	%rbx
	subq	$40, %rsp
.Ltmp109:
	.cfi_offset %rbx, -40
.Ltmp110:
	.cfi_offset %rdi, -32
.Ltmp111:
	.cfi_offset %rsi, -24
	movq	%rdx, %rdi
	movq	%rcx, %rsi
	movq	jl_page_size(%rip), %rbx
	movl	$640, %ecx
	callq	allocobj
	movq	jl_task_type(%rip), %rcx
	movq	%rcx, (%rax)
	leaq	-1(%rdi,%rbx), %rcx
	negq	%rbx
	andq	%rcx, %rbx
	movq	%rbx, 608(%rax)
	movq	$0, 8(%rax)
	movq	jl_current_task(%rip), %rcx
	movq	%rcx, 16(%rax)
	movq	jl_current_task(%rip), %rcx
	movq	24(%rcx), %rcx
	movq	%rcx, 24(%rax)
	movq	jl_nothing(%rip), %rcx
	movq	%rcx, 32(%rax)
	movb	$0, 40(%rax)
	movb	$1, 41(%rax)
	movq	%rsi, 616(%rax)
	movq	$0, 48(%rax)
	movq	$0, 600(%rax)
	movq	$0, 592(%rax)
	movq	$0, 632(%rax)
	movq	$0, 624(%rax)
	addq	$40, %rsp
	popq	%rbx
	popq	%rdi
	popq	%rsi
	popq	%rbp
	ret
	.cfi_endproc

	.def	 jl_unprotect_stack;
	.scl	2;
	.type	32;
	.endef
	.globl	jl_unprotect_stack
	.align	16, 0x90
jl_unprotect_stack:
	.cfi_startproc
	movq	jl_null(%rip), %rax
	ret
	.cfi_endproc

	.def	 jl_f_task;
	.scl	2;
	.type	32;
	.endef
	.globl	jl_f_task
	.align	16, 0x90
jl_f_task:
	.cfi_startproc
	pushq	%rbp
.Ltmp115:
	.cfi_def_cfa_offset 16
.Ltmp116:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
.Ltmp117:
	.cfi_def_cfa_register %rbp
	pushq	%rsi
	pushq	%rdi
	pushq	%rbx
	subq	$40, %rsp
.Ltmp118:
	.cfi_offset %rbx, -40
.Ltmp119:
	.cfi_offset %rdi, -32
.Ltmp120:
	.cfi_offset %rsi, -24
	movl	%r8d, %edi
	movq	%rdx, %rsi
	testl	%edi, %edi
	je	.LBB17_1
	cmpl	$3, %edi
	jb	.LBB17_4
	movl	$.L.str2, %ecx
	movl	$2, %edx
	callq	jl_too_many_args
	jmp	.LBB17_4
.LBB17_1:
	movl	$.L.str2, %ecx
	movl	$1, %edx
	callq	jl_too_few_args
.LBB17_4:
	movq	(%rsi), %r8
	movq	(%r8), %rax
	movq	jl_function_type(%rip), %rdx
	cmpq	%rdx, %rax
	je	.LBB17_7
	cmpq	jl_struct_kind(%rip), %rax
	je	.LBB17_7
	movl	$.L.str2, %ecx
	callq	jl_type_error
.LBB17_7:
	movl	$196607, %ebx
	cmpl	$2, %edi
	jne	.LBB17_12
	movq	8(%rsi), %r8
	movq	(%r8), %rax
	movq	jl_int64_type(%rip), %rdx
	cmpq	%rdx, %rax
	je	.LBB17_10
	movl	$.L.str2, %ecx
	callq	jl_type_error
	movq	8(%rsi), %r8
.LBB17_10:
	movq	%r8, %rcx
	callq	jl_unbox_int64
	movq	%rax, %rbx
	cmpq	$32768, %rbx
	jb	.LBB17_13
	decq	%rbx
.LBB17_12:
	movq	(%rsi), %rsi
	movq	jl_page_size(%rip), %rdi
	movl	$640, %ecx
	callq	allocobj
	movq	jl_task_type(%rip), %rcx
	movq	%rcx, (%rax)
	addq	%rdi, %rbx
	negq	%rdi
	andq	%rbx, %rdi
	movq	%rdi, 608(%rax)
	movq	$0, 8(%rax)
	movq	jl_current_task(%rip), %rcx
	movq	%rcx, 16(%rax)
	movq	jl_current_task(%rip), %rcx
	movq	24(%rcx), %rcx
	movq	%rcx, 24(%rax)
	movq	jl_nothing(%rip), %rcx
	movq	%rcx, 32(%rax)
	movb	$0, 40(%rax)
	movb	$1, 41(%rax)
	movq	%rsi, 616(%rax)
	movq	$0, 48(%rax)
	movq	$0, 600(%rax)
	movq	$0, 592(%rax)
	movq	$0, 632(%rax)
	movq	$0, 624(%rax)
	addq	$40, %rsp
	popq	%rbx
	popq	%rdi
	popq	%rsi
	popq	%rbp
	ret
.LBB17_13:
	movl	$.L.str3, %ecx
	callq	jl_error
	.cfi_endproc

	.def	 jl_f_yieldto;
	.scl	2;
	.type	32;
	.endef
	.globl	jl_f_yieldto
	.align	16, 0x90
jl_f_yieldto:
	.cfi_startproc
	pushq	%rbp
.Ltmp124:
	.cfi_def_cfa_offset 16
.Ltmp125:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
.Ltmp126:
	.cfi_def_cfa_register %rbp
	pushq	%rsi
	pushq	%rdi
	subq	$32, %rsp
.Ltmp127:
	.cfi_offset %rdi, -32
.Ltmp128:
	.cfi_offset %rsi, -24
	movl	%r8d, %edi
	movq	%rdx, %rsi
	testl	%edi, %edi
	jne	.LBB18_2
	movl	$.L.str4, %ecx
	movl	$1, %edx
	callq	jl_too_few_args
.LBB18_2:
	movq	(%rsi), %r8
	movq	(%r8), %rax
	movq	jl_task_type(%rip), %rdx
	cmpq	%rdx, %rax
	je	.LBB18_4
	movl	$.L.str4, %ecx
	callq	jl_type_error
.LBB18_4:
	leal	-1(%rdi), %eax
	movl	%eax, n_args_in_transit(%rip)
	cmpl	$2, %edi
	jne	.LBB18_6
	movq	8(%rsi), %rax
	jmp	.LBB18_9
.LBB18_6:
	cmpl	$3, %edi
	jb	.LBB18_8
	movl	n_args_in_transit(%rip), %r8d
	leaq	8(%rsi), %rdx
	xorl	%ecx, %ecx
	callq	jl_f_tuple
	jmp	.LBB18_9
.LBB18_8:
	movq	jl_null(%rip), %rax
.LBB18_9:
	movq	%rax, jl_task_arg_in_transit(%rip)
	movq	(%rsi), %rcx
	cmpb	$0, 40(%rcx)
	je	.LBB18_11
	movq	jl_null(%rip), %rax
	movq	%rax, jl_task_arg_in_transit(%rip)
	movq	48(%rcx), %rax
	jmp	.LBB18_12
.LBB18_11:
	leaq	64(%rcx), %rdx
	callq	ctx_switch
	movq	jl_task_arg_in_transit(%rip), %rax
	movq	jl_null(%rip), %rcx
	movq	%rcx, jl_task_arg_in_transit(%rip)
.LBB18_12:
	addq	$32, %rsp
	popq	%rdi
	popq	%rsi
	popq	%rbp
	ret
	.cfi_endproc

	.def	 jl_get_current_task;
	.scl	2;
	.type	32;
	.endef
	.globl	jl_get_current_task
	.align	16, 0x90
jl_get_current_task:
	.cfi_startproc
	movq	jl_current_task(%rip), %rax
	ret
	.cfi_endproc

	.def	 jl_init_tasks;
	.scl	2;
	.type	32;
	.endef
	.globl	jl_init_tasks
	.align	16, 0x90
jl_init_tasks:
	.cfi_startproc
	pushq	%rbp
.Ltmp132:
	.cfi_def_cfa_offset 16
.Ltmp133:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
.Ltmp134:
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rsi
	pushq	%rdi
	pushq	%rbx
	subq	$1112, %rsp
.Ltmp135:
	.cfi_offset %rbx, -240
.Ltmp136:
	.cfi_offset %rdi, -232
.Ltmp137:
	.cfi_offset %rsi, -224
.Ltmp138:
	.cfi_offset %r12, -216
.Ltmp139:
	.cfi_offset %r13, -208
.Ltmp140:
	.cfi_offset %r14, -200
.Ltmp141:
	.cfi_offset %r15, -192
.Ltmp142:
	.cfi_offset %xmm6, -168
.Ltmp143:
	.cfi_offset %xmm7, -152
.Ltmp144:
	.cfi_offset %xmm8, -136
.Ltmp145:
	.cfi_offset %xmm9, -120
.Ltmp146:
	.cfi_offset %xmm10, -104
.Ltmp147:
	.cfi_offset %xmm11, -88
.Ltmp148:
	.cfi_offset %xmm12, -72
.Ltmp149:
	.cfi_offset %xmm13, -56
.Ltmp150:
	.cfi_offset %xmm14, -40
.Ltmp151:
	.cfi_offset %xmm15, -24
	movaps	%xmm15, -224(%rbp)
	movaps	%xmm14, -208(%rbp)
	movaps	%xmm13, -192(%rbp)
	movaps	%xmm12, -176(%rbp)
	movaps	%xmm11, -160(%rbp)
	movaps	%xmm10, -144(%rbp)
	movaps	%xmm9, -128(%rbp)
	movaps	%xmm8, -112(%rbp)
	movaps	%xmm7, -96(%rbp)
	movaps	%xmm6, -80(%rbp)
	movq	%rdx, -1088(%rbp)
	movq	%rcx, -1080(%rbp)
	leaq	-1040(%rbp), %rcx
	xorl	%edx, %edx
	movl	$768, %r8d
	callq	memset
	leaq	-528(%rbp), %rax
	movq	%rax, -272(%rbp)
	leaq	-1072(%rbp), %rsi
	movq	%rsi, %rcx
	callq	fill
	leaq	-248(%rbp), %rcx
	leaq	-240(%rbp), %rax
	movq	%rsi, -248(%rbp)
	movq	%rcx, -1072(%rbp)
	movq	%rsi, -240(%rbp)
	movq	-1064(%rbp), %rcx
	movq	%rcx, -1048(%rbp)
	movq	%rax, -1064(%rbp)
	movq	-272(%rbp), %rax
	movq	%rbp, (%rax)
	movq	%rsp, 16(%rax)
	movq	$".LBB20_-1", 8(%rax)
	#EH_SjLj_Setup	.LBB20_1
.LBB20_1:
	movq	-240(%rbp), %rax
	leaq	32(%rax), %rcx
	movq	%rcx, 800(%rax)
	movq	-240(%rbp), %rax
	movq	%rbp, 288(%rax)
	movq	%rsp, 304(%rax)
	movq	$".LBB20_-1", 296(%rax)
	#EH_SjLj_Setup	.LBB20_2
.LBB20_2:
	movq	-240(%rbp), %rax
	leaq	-228(%rbp), %rcx
	movq	%rcx, 16(%rax)
	movq	-1064(%rbp), %rax
	subq	-1048(%rbp), %rax
	movl	%eax, %ecx
	negl	%ecx
	testl	%eax, %eax
	cmovnsq	%rax, %rcx
	movslq	%ecx, %rax
	movq	%rax, _frame_offset(%rip)
	movl	$.L.str2, %ecx
	callq	jl_symbol
	movq	%rax, -1096(%rbp)
	movq	jl_null(%rip), %rax
	movq	%rax, -1104(%rbp)
	movq	jl_any_type(%rip), %r12
	movl	$.L.str5, %ecx
	callq	jl_symbol
	movq	%rax, %r13
	movl	$.L.str6, %ecx
	callq	jl_symbol
	movq	%rax, %rdi
	movl	$.L.str7, %ecx
	callq	jl_symbol
	movq	%rax, %rbx
	movl	$.L.str8, %ecx
	callq	jl_symbol
	movq	%rax, %rsi
	movl	$.L.str9, %ecx
	callq	jl_symbol
	movq	%rax, %r14
	movl	$.L.str10, %ecx
	callq	jl_symbol
	movq	%rax, %r15
	movl	$.L.str11, %ecx
	callq	jl_symbol
	movq	%rax, 56(%rsp)
	movq	%r15, 48(%rsp)
	movq	%r14, 40(%rsp)
	movq	%rsi, 32(%rsp)
	movl	$7, %ecx
	movq	%r13, %rdx
	movq	%rdi, %r8
	movq	%rbx, %r9
	callq	jl_tuple
	movq	%rax, %rsi
	movq	jl_bool_type(%rip), %rax
	movq	jl_any_type(%rip), %rdx
	movq	%rdx, 56(%rsp)
	movq	%rax, 48(%rsp)
	movq	%rax, 40(%rsp)
	movq	%rdx, 32(%rsp)
	movl	$7, %ecx
	movq	%rdx, %r8
	movq	%rdx, %r9
	callq	jl_tuple
	movq	%rax, 32(%rsp)
	movq	-1096(%rbp), %rcx
	movq	%r12, %rdx
	movq	-1104(%rbp), %r8
	movq	%rsi, %r9
	callq	jl_new_struct_type
	movq	-1080(%rbp), %rsi
	addq	-1088(%rbp), %rsi
	movq	%rax, jl_task_type(%rip)
	movq	64(%rax), %rcx
	movq	%rax, 16(%rcx)
	movq	jl_task_type(%rip), %rax
	movq	$jl_f_task, 8(%rax)
	movl	$640, %ecx
	callq	allocobj
	movq	%rax, jl_current_task(%rip)
	movq	jl_task_type(%rip), %rax
	movq	jl_current_task(%rip), %rcx
	movq	%rax, (%rcx)
	movq	jl_current_task(%rip), %rax
	movq	%rsi, 320(%rax)
	movq	jl_current_task(%rip), %rax
	movq	$0, 608(%rax)
	movq	jl_current_task(%rip), %rax
	movq	$0, 592(%rax)
	movq	jl_current_task(%rip), %rax
	movq	$0, 600(%rax)
	movq	jl_current_task(%rip), %rax
	movq	jl_current_task(%rip), %rcx
	movq	%rax, 8(%rcx)
	movq	jl_current_task(%rip), %rax
	movq	jl_current_task(%rip), %rcx
	movq	%rax, 16(%rcx)
	movq	jl_current_task(%rip), %rax
	movq	$0, 24(%rax)
	movq	jl_current_task(%rip), %rax
	movq	$0, 32(%rax)
	movq	jl_current_task(%rip), %rax
	movb	$0, 40(%rax)
	movq	jl_current_task(%rip), %rax
	movb	$1, 41(%rax)
	movq	jl_current_task(%rip), %rax
	movq	$0, 616(%rax)
	movq	jl_current_task(%rip), %rax
	movq	$0, 48(%rax)
	movq	jl_current_task(%rip), %rax
	movq	$0, 624(%rax)
	movq	jl_current_task(%rip), %rax
	movq	$0, 632(%rax)
	movq	jl_current_task(%rip), %rax
	movq	%rax, jl_root_task(%rip)
	movq	jl_null(%rip), %rdx
	movq	%rdx, jl_exception_in_transit(%rip)
	movq	%rdx, jl_task_arg_in_transit(%rip)
	movl	$jl_unprotect_stack, %ecx
	xorl	%r8d, %r8d
	callq	jl_new_closure
	movq	%rax, jl_unprotect_stack_func(%rip)
	movaps	-80(%rbp), %xmm6
	movaps	-96(%rbp), %xmm7
	movaps	-112(%rbp), %xmm8
	movaps	-128(%rbp), %xmm9
	movaps	-144(%rbp), %xmm10
	movaps	-160(%rbp), %xmm11
	movaps	-176(%rbp), %xmm12
	movaps	-192(%rbp), %xmm13
	movaps	-208(%rbp), %xmm14
	movaps	-224(%rbp), %xmm15
	addq	$1112, %rsp
	popq	%rbx
	popq	%rdi
	popq	%rsi
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	ret
	.cfi_endproc

	.def	 fill;
	.scl	3;
	.type	32;
	.endef
	.align	16, 0x90
fill:
	.cfi_startproc
	pushq	%rbp
.Ltmp155:
	.cfi_def_cfa_offset 16
.Ltmp156:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
.Ltmp157:
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rsi
	pushq	%rdi
	pushq	%rbx
	subq	$200, %rsp
.Ltmp158:
	.cfi_offset %rbx, -240
.Ltmp159:
	.cfi_offset %rdi, -232
.Ltmp160:
	.cfi_offset %rsi, -224
.Ltmp161:
	.cfi_offset %r12, -216
.Ltmp162:
	.cfi_offset %r13, -208
.Ltmp163:
	.cfi_offset %r14, -200
.Ltmp164:
	.cfi_offset %r15, -192
.Ltmp165:
	.cfi_offset %xmm6, -168
.Ltmp166:
	.cfi_offset %xmm7, -152
.Ltmp167:
	.cfi_offset %xmm8, -136
.Ltmp168:
	.cfi_offset %xmm9, -120
.Ltmp169:
	.cfi_offset %xmm10, -104
.Ltmp170:
	.cfi_offset %xmm11, -88
.Ltmp171:
	.cfi_offset %xmm12, -72
.Ltmp172:
	.cfi_offset %xmm13, -56
.Ltmp173:
	.cfi_offset %xmm14, -40
.Ltmp174:
	.cfi_offset %xmm15, -24
	movaps	%xmm15, -224(%rbp)
	movaps	%xmm14, -208(%rbp)
	movaps	%xmm13, -192(%rbp)
	movaps	%xmm12, -176(%rbp)
	movaps	%xmm11, -160(%rbp)
	movaps	%xmm10, -144(%rbp)
	movaps	%xmm9, -128(%rbp)
	movaps	%xmm8, -112(%rbp)
	movaps	%xmm7, -96(%rbp)
	movaps	%xmm6, -80(%rbp)
	movq	%rcx, -248(%rbp)
	leaq	-248(%rbp), %rax
	movq	%rax, (%rcx)
	movq	%rcx, -240(%rbp)
	movq	8(%rcx), %rax
	movq	%rax, 24(%rcx)
	leaq	-240(%rbp), %rax
	movq	%rax, 8(%rcx)
	movq	800(%rcx), %rax
	movq	%rbp, (%rax)
	movq	%rsp, 16(%rax)
	movq	$".LBB21_-1", 8(%rax)
	#EH_SjLj_Setup	.LBB21_1
.LBB21_1:
	movq	-240(%rbp), %rax
	leaq	32(%rax), %rcx
	movq	%rcx, 800(%rax)
	movq	-240(%rbp), %rax
	movq	%rbp, 288(%rax)
	movq	%rsp, 304(%rax)
	movq	$".LBB21_-1", 296(%rax)
	#EH_SjLj_Setup	.LBB21_2
.LBB21_2:
	movq	-240(%rbp), %rax
	leaq	-228(%rbp), %rcx
	movq	%rcx, 16(%rax)
	movaps	-80(%rbp), %xmm6
	movaps	-96(%rbp), %xmm7
	movaps	-112(%rbp), %xmm8
	movaps	-128(%rbp), %xmm9
	movaps	-144(%rbp), %xmm10
	movaps	-160(%rbp), %xmm11
	movaps	-176(%rbp), %xmm12
	movaps	-192(%rbp), %xmm13
	movaps	-208(%rbp), %xmm14
	movaps	-224(%rbp), %xmm15
	addq	$200, %rsp
	popq	%rbx
	popq	%rdi
	popq	%rsi
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	ret
	.cfi_endproc

	.def	 ctx_switch;
	.scl	3;
	.type	32;
	.endef
	.align	16, 0x90
ctx_switch:
	.cfi_startproc
	pushq	%rbp
.Ltmp178:
	.cfi_def_cfa_offset 16
.Ltmp179:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
.Ltmp180:
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rsi
	pushq	%rdi
	pushq	%rbx
	subq	$232, %rsp
.Ltmp181:
	.cfi_offset %rbx, -240
.Ltmp182:
	.cfi_offset %rdi, -232
.Ltmp183:
	.cfi_offset %rsi, -224
.Ltmp184:
	.cfi_offset %r12, -216
.Ltmp185:
	.cfi_offset %r13, -208
.Ltmp186:
	.cfi_offset %r14, -200
.Ltmp187:
	.cfi_offset %r15, -192
.Ltmp188:
	.cfi_offset %xmm6, -168
.Ltmp189:
	.cfi_offset %xmm7, -152
.Ltmp190:
	.cfi_offset %xmm8, -136
.Ltmp191:
	.cfi_offset %xmm9, -120
.Ltmp192:
	.cfi_offset %xmm10, -104
.Ltmp193:
	.cfi_offset %xmm11, -88
.Ltmp194:
	.cfi_offset %xmm12, -72
.Ltmp195:
	.cfi_offset %xmm13, -56
.Ltmp196:
	.cfi_offset %xmm14, -40
.Ltmp197:
	.cfi_offset %xmm15, -24
	movaps	%xmm15, -224(%rbp)
	movaps	%xmm14, -208(%rbp)
	movaps	%xmm13, -192(%rbp)
	movaps	%xmm12, -176(%rbp)
	movaps	%xmm11, -160(%rbp)
	movaps	%xmm10, -144(%rbp)
	movaps	%xmm9, -128(%rbp)
	movaps	%xmm8, -112(%rbp)
	movaps	%xmm7, -96(%rbp)
	movaps	%xmm6, -80(%rbp)
	movq	%rdx, -240(%rbp)
	movq	%rcx, -248(%rbp)
	movq	jl_current_task(%rip), %rax
	cmpq	%rcx, %rax
	je	.LBB22_12
	movq	jl_current_task(%rip), %rax
	movq	%rbp, 64(%rax)
	movq	%rsp, 80(%rax)
	movq	$.LBB22_13, 72(%rax)
	#EH_SjLj_Setup	.LBB22_13
	xorl	%eax, %eax
	jmp	.LBB22_3
.LBB22_13:
	movl	$1, %eax
.LBB22_3:
	testl	%eax, %eax
	je	.LBB22_4
.LBB22_12:
	movaps	-80(%rbp), %xmm6
	movaps	-96(%rbp), %xmm7
	movaps	-112(%rbp), %xmm8
	movaps	-128(%rbp), %xmm9
	movaps	-144(%rbp), %xmm10
	movaps	-160(%rbp), %xmm11
	movaps	-176(%rbp), %xmm12
	movaps	-192(%rbp), %xmm13
	movaps	-208(%rbp), %xmm14
	movaps	-224(%rbp), %xmm15
	addq	$232, %rsp
	popq	%rbx
	popq	%rdi
	popq	%rsi
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	ret
.LBB22_4:
	movq	jl_current_task(%rip), %rdi
	cmpb	$0, 40(%rdi)
	jne	.LBB22_9
	movq	320(%rdi), %rsi
	movq	600(%rdi), %rax
	leaq	-228(%rbp), %rcx
	subq	%rcx, %rsi
	testq	%rax, %rax
	je	.LBB22_7
	cmpq	%rsi, 592(%rdi)
	jae	.LBB22_8
.LBB22_7:
	movq	%rsi, %rcx
	callq	allocb
	movq	%rax, 600(%rdi)
	movq	%rsi, 592(%rdi)
.LBB22_8:
	movq	%rsi, 608(%rdi)
	leaq	-228(%rbp), %rdx
	movq	%rax, %rcx
	movq	%rsi, %r8
	callq	memcpy
.LBB22_9:
	movq	jl_pgcstack(%rip), %rax
	movq	jl_current_task(%rip), %rcx
	movq	%rax, 632(%rcx)
	movq	-248(%rbp), %rcx
	movq	632(%rcx), %rax
	movq	%rax, jl_pgcstack(%rip)
	movq	jl_current_task(%rip), %rax
	movq	%rax, 16(%rcx)
	cmpq	$0, 8(%rcx)
	jne	.LBB22_11
	movq	jl_current_task(%rip), %rax
	movq	%rax, 8(%rcx)
.LBB22_11:
	movq	%rcx, jl_current_task(%rip)
	movq	-240(%rbp), %rax
	movq	%rax, jl_jmp_target(%rip)
	movq	336(%rdi), %rbp
	movq	344(%rdi), %rax
	movq	352(%rdi), %rsp
	jmpq	*%rax
	.cfi_endproc

	.data
	.globl	jl_pgcstack
	.align	8
jl_pgcstack:
	.quad	0

	.globl	jl_jmp_target
	.align	8
jl_jmp_target:
	.quad	0

	.globl	jl_task_arg_in_transit
	.align	8
jl_task_arg_in_transit:
	.quad	0

	.lcomm	n_args_in_transit,4,4
	.lcomm	bt_data,640008,16
	.lcomm	bt_size,8,8
.L.str:
	.asciz	 "%s at %s: offset %x\n"

.L.str1:
	.asciz	 "%s at %s:%d\n"

	.globl	jl_exception_in_transit
	.align	8
jl_exception_in_transit:
	.quad	0

	.globl	jl_task_type
	.align	8
jl_task_type:
	.quad	0

	.globl	jl_current_task
	.align	8
jl_current_task:
	.quad	0

.L.str2:
	.asciz	 "Task"

.L.str3:
	.asciz	 "Task: stack size too small"

.L.str4:
	.asciz	 "yieldto"

.L.str5:
	.asciz	 "parent"

.L.str6:
	.asciz	 "last"

.L.str7:
	.asciz	 "storage"

.L.str8:
	.asciz	 "consumers"

.L.str9:
	.asciz	 "done"

.L.str10:
	.asciz	 "runnable"

.L.str11:
	.asciz	 "result"

	.globl	jl_root_task
	.align	8
jl_root_task:
	.quad	0

	.globl	jl_unprotect_stack_func
	.align	8
jl_unprotect_stack_func:
	.quad	0

	.lcomm	_frame_offset,8,8
.L.str12:
	.asciz	 "???"


	.section	.drectve,"r"
	.ascii	 " -export:jl_pgcstack,data"
	.ascii	 " -export:jl_exception_in_transit,data"
	.ascii	 " -export:jl_current_task,data"
	.ascii	 " -export:jl_root_task,data"
	.ascii	 " -export:jl_parse_backtrace"
	.ascii	 " -export:jl_get_backtrace"
	.ascii	 " -export:rec_backtrace"
	.ascii	 " -export:gdblookup"
	.ascii	 " -export:gdbbacktrace"
	.ascii	 " -export:jlbacktrace"
	.ascii	 " -export:jl_throw"
	.ascii	 " -export:jl_rethrow"
	.ascii	 " -export:jl_rethrow_other"
	.ascii	 " -export:jl_throw_with_superfluous_argument"
	.ascii	 " -export:jl_get_current_task"
