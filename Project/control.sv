// State machine control unit
// Zuofu is my dad

module control (

);

enum logic [7:0] { // 56 total instructions
	fetch, // fetch states
	decode_01,  // decode states
	ADC, // - Add with Carry
   SBC, // - Subtract with Carry
   AND, // Logical AND
   EOR, // Exclusive OR
   ORA, // Logical Inclusive OR
   BIT, // Bit Test
   CMP, // Compare
   CPX, // Compare X Register
   CPY, // Compare Y Register
   DEC, // Decrement Memory
   DEX, // Decrement X Register
   DEY, // Decrement Y Register
   INC, // Increment Memory
   INX, // Increment X Register
   INY, // Increment Y Register
   ASL, // Arithmetic Shift Left
   LSR, // Logical Shift Right
   ROL, // Rotate Left
   ROR, // Rotate Right

   LDA, // Load Accumulator
   LDX, // Load X Register
   LDY, // Load Y Register
   STA, // Store Accumulator
   STX, // Store X Register
   STY, // Store Y Register
   TAX, // Transfer Accumulator to X
   TAY, // Transfer Accumulator to Y
   TXA, // Transfer X to Accumulator
   TYA, // Transfer Y to Accumulator

   BCC, // Branch on Carry Clear
   BCS, // Branch on Carry Set
   BEQ, // Branch on Equal
   BMI, // Branch on Minus
   BNE, // Branch on Not Equal
   BPL, // Branch on Plus
   BVC, // Branch on Overflow Clear
   BVS, // Branch on Overflow Set
   JMP, // Jump
   JSR, // Jump to Subroutine
   RTS, // Return from Subroutine

   PHA, // Push Accumulator
   PHP, // Push Processor Status
   PLA, // Pull Accumulator
   PLP, // Pull Processor Status 
	
   CLC, // Clear Carry Flag
   CLD, // Clear Decimal Mode
   CLI, // Clear Interrupt Disable
   CLV, // Clear Overflow Flag
   SEC, // Set Carry Flag
   SED, // Set Decimal Mode
   SEI, // Set Interrupt Disable
   NOP, // No Operation
   BRK, // Break
   RTI, // Return from Interrupt
   TXS, // Transfer X to Stack Pointer
   TSX, // Transfer Stack Pointer to X
	} State, Next_state;
	
always_ff @ (posedge Clk)
begin
		State <= Next_state;
end

always_comb
begin
	case (State)
		fetch: ;
		decode_01: ; 
		ADC: ;
		SBC: ;
		AND: ;
		EOR: ;
		ORA: ;
		BIT: ;
		CMP: ;
		CPX: ;
		CPY: ;
		DEC: ;
		DEX: ;
		DEY: ;
		INC: ;
		INX: ;
		INY: ;
		ASL: ;
		LSR: ;
		ROL: ;
		ROR: ;

		LDA: ;
		LDX: ;
		LDY: ;
		STA: ;
		STX: ;
		STY: ;
		TAX: ;
		TAY: ;
		TXA: ;
		TYA: ;

		BCC: ;
		BCS: ;
		BEQ: ;
		BMI: ;
		BNE: ;
		BPL: ;
		BVC: ;
		BVS: ;
		JMP: ;
		JSR: ;
		RTS: ;

		PHA: ;
		PHP: ;
		PLA: ;
		PLP: ;
		
		CLC: ;
		CLD: ;
		CLI: ;
		CLV: ;
		SEC: ;
		SED: ;
		SEI: ;
		NOP: ;
		BRK: ;
		RTI: ;
		TXS: ;
		TSX: ;
		default :
			Next_state = State;
	endcase
end


endmodule 