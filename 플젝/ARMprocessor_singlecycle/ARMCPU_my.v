modu                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            0] ALUFlags,
   output RegSrcOut,
   output  MemtoRegOut
);

   wire [31:0] SrcB; 
   reg [31:0] actual_data1, actual_data2, actual_data3;
   
   always @(*)
   begin 
      case(fwd_signal1In)
         2'b00: actual_data1 = data1In;
         2'b01: actual_data1 = ResultWB;
         2'b10: actual_data1 = ResultMEM;
       default: actual_data1 = data1In;
      endcase
   
      case(fwd_signal2In)
         2'b00: actual_data2 = data2In;
         2'b01: actual_data2 = ResultWB;
         2'b10: actual_data2 = ResultMEM;
       default: actual_data2 = data2In;
      endcase

  
      case(fwd_signal3In)
         2'b00: actual_data3 = data3In;
         2'b01: actual_data3 = ResultWB;
         2'b10: actual_data3 = ResultMEM;
       default: actual_data3 = data3In;
      endcase
   end
   
   
   assign SrcB = (ALUSrc == 1'b0) ? actual_data2 : Ext_immIn;
   ALU32bit _ALU32bit(.SrcA(actual_data1), .SrcB(SrcB), .ALUOp(ALUOp), .ALUFlags(ALUFlags), .ALUResult(ALUResult) );
   
   assign PCBranch = PCPlus4In + Ext_immIn + 32'd4;
   assign data3Out = actual_data3;
   assign waddrOut = waddrIn;
   
   assign RegSrcOut = RegSrcIn;
   assign MemtoRegOut = MemtoRegIn;

endmodule


            
module EX_MEM_Register(
   input clk,
   input reset,
   input [31:0] PCBranchIn,
   input [31:0] ALUResultIn,
   input [31:0] wdataMIn, // to Memory
   input [3:0] waddrIn, 
   // control signal
   input PCSrcIn, RegWriteIn, MemWriteIn, MemtoRegIn, RegSrcIn, memreadIn,

   output reg [31:0] PCBranchOut,
   output reg [31:0] ALUResultOut,
   output reg [31:0] wdataMOut,
   output reg [3:0] waddrOut,
   output reg [31:0] memaddr,
   output reg PCSrcOut, RegWriteOut, MemWriteOut, MemtoRegOut, RegSrcOut, memreadOut
   
   );
   
   
   
  always @ (negedge clk)
   begin

      if(reset)
      begin
         PCBranchOut <= 'h00000000;
         ALUResultOut <= 'h00000000;
         wdataMOut <= 'h00000000;
         memaddr <= 'h00000000;
         waddrOut <= 'h0;
         PCSrcOut <= 'b0; 
         RegWriteOut <= 'b0; 
         MemWriteOut <= 'b0;
         MemtoRegOut <= 'b0;
         RegSrcOut <= 'b0;
         memreadOut <= 'b0;
      end
      else
      begin
         PCBranchOut <= PCBranchIn;
         ALUResultOut <= ALUResultIn;
         wdataMOut  <= wdataMIn;
         waddrOut  <= waddrIn;
         PCSrcOut <= PCSrcIn;
         RegWriteOut <= RegWriteIn;
         MemWriteOut <= MemWriteIn;
         MemtoRegOut <= MemtoRegIn;
         RegSrcOut <= RegSrcIn;
         memaddr <= ALUResultIn;
         memreadOut <= memreadIn;
      end
    end

endmodule






module MEM_stage (
   input RegWriteIn, MemtoRegIn,
   input RegSrcIn,
   input [31:0] ALUResultIn,
   input [3:0] waddrIn,
   
   output [31:0] ALUResultOut,
   output [3:0] waddrOut,
   output RegSrcOut,
   output RegWriteOut, MemtoRegOut
);

   assign waddrOut = waddrIn;
   assign RegSrcOut = RegSrcIn;
   assign RegWriteOut = RegWriteIn;
   assign MemtoRegOut = MemtoRegIn;
   assign ALUResultOut = ALUResultIn;
   
endmodule


module MEM_WB_Register (
   input clk,
   input reset,
   input RegSrcIn,
   input MemtoRegIn,
   input RegWriteIn,
   input [31:0] readdataIn, 
   input [31:0] ALUResultIn ,
   input [3:0] waddrIn ,
   output reg [31:0] readdataOut ,
   output reg [31:0] ALUResultOut ,
   output reg [3:0] waddrOut ,
   output reg MemtoRegOut,
   output reg RegWriteOut,
   output reg RegSrcOut
);
   
   always @ (negedge clk)
   begin
      if(reset)
      begin
         readdataOut <= 'h00000000;
         ALUResultOut <= 'h00000000;
         waddrOut <= 'h0;
         MemtoRegOut <= 'b0;
         RegWriteOut <= 'b0;
         RegSrcOut <= 'b0;
      end
      else
      begin
       RegSrcOut = RegSrcIn;
         readdataOut = readdataIn;
         ALUResultOut = ALUResultIn;
         waddrOut = waddrIn;
         MemtoRegOut = MemtoRegIn;
         RegWriteOut = RegWriteIn;
      end
    end

   
endmodule


module WB_stage(
   input MemtoReg,
   input [31:0] readata,
   input [31:0] ALUResult,
   output [31:0] Result
);
   assign Result = (MemtoReg == 1'b0) ? ALUResult : readata;
endmodule
       



   
   
   



module ExtendMUX(
    input[23:0] in,

    input[1:0] ImmSrc,
    output reg[31:0] ExtImm
    );
 
   integer i;
   always @ (*)
   begin
      case(ImmSrc)
      2'b00:
      begin
         ExtImm[7:0] = in[7:0];
         for(i=8;i<32;i=i+1)
            ExtImm[i] = in[7];
      end
      2'b01:
      begin
         ExtImm[11:0] = in[11:0];
         for(i=12;i<32;i=i+1)
            ExtImm[i] = 'b0;
      end
      2'b10:
      begin
         ExtImm[1:0] = 2'b00;
         ExtImm[25:2] = in[23:0];
         for(i=26;i<32;i=i+1)
            ExtImm[i] = in[23];
      end
      default:
      begin
         ExtImm[31:0] = { in , 8'b00000000};
         i=0;
      end
      endcase
   end
endmodule

module PC_update(
   input clk,
   input reset,
   input enable,

   input [31:0] PCIn,
   input WtoPCWB,
   input [31:0] wdata,

   output reg [31:0] PCOut   
) ;
   always @(negedge clk)
   begin 
      if(reset)
         PCOut <= 'h00000000;
      else begin
         if (enable) begin
            if(WtoPCWB) begin
               PCOut = wdata;
         end 
         else PCOut = PCIn;
        end
     
               
     end
            
   end
   
endmodule   

module RegisterFile(
   input clk,
   input reset,
   input we,
   input[1:0] RegSrc,
   input[3:0] addr1,
   input[3:0] addr2,
   input[3:0] addr3,
   input[3:0] waddr,
   input[31:0] wdata,
   input[31:0] pcin,
   output reg[31:0] data1,
   output reg[31:0] data2,
   output reg[31:0] data3
   );
   
   reg[31:0] registers[15:0];
   integer idx;
    
   // write to register file
   always @ (posedge clk)
   begin
      if (reset)
      begin
         for(idx=0; idx<=15; idx=idx+1) begin
            registers[idx] = 'h00000000;
         end
      end
      else
      begin
         if(we)
         begin
            if(RegSrc[0] != 1'b1)
               registers[waddr] = wdata;
            else 
               registers[14] = registers[15]; //r15??? pc, r14??? link reg
       end
      if(waddr != 4'b1111 || RegSrc[0] == 1'b1)
         registers[15] = pcin;

      end
   end
   
   // read from register file
   always @ (*)
   begin
      if (reset) //reset 
      begin
         data1 <= 'h00000000;
         data2 <= 'h00000000;
         data3 <= 'h00000000;
      end
     
      else
      begin
         if (addr1 == 15) 
       begin
            data1 = registers[15] + 32'd4;
         end
       
         else 
       begin
            data1 = registers[addr1];
         end
         
         if (addr2 == 15) 
       begin
            data2 = registers[15] + 32'd4;
         end
         else
         begin
            // RegSrc MUX
            if (RegSrc[1] == 1'b0)
               data2 = registers[addr2];
            else
               data2 = registers[waddr];
         end
       
         if (addr3 == 15) begin
            data3 = registers[15] + 32'd4;
         end
         else begin
            data3 = registers[addr3];
         end
      end
   end

endmodule


//forwarding Unit
module Forwarding_Unit(
   input RegWriteMEM1In,
   input RegWriteWBIn,
   input [3:0] fwdaddr1In,
   input [3:0] fwdaddr2In,
   input [3:0] fwdaddr3In,
   input [3:0] WriteAddrMEM1In,
   input [3:0] WriteAddrWBIn,   
   output reg [1:0] fwd_data1,
   output reg [1:0] fwd_data2,
   output reg [1:0] fwd_data3
);

reg [1:0] tmp;

always @ (*)
begin
tmp = { RegWriteMEM1In, RegWriteWBIn};
if( tmp == 2'b11)
   begin
      if(fwdaddr1In == WriteAddrMEM1In)
          fwd_data1 <= 2'b10;
      else if (fwdaddr1In == WriteAddrWBIn)
            fwd_data1 <= 2'b01;
      else 
         fwd_data1 <= 2'b00;
      if(fwdaddr2In == WriteAddrMEM1In)
          fwd_data2 <= 2'b10;
      else if (fwdaddr2In == WriteAddrWBIn)
            fwd_data2 <= 2'b01;
      else 
         fwd_data2 <= 2'b00;

      if(fwdaddr3In == WriteAddrMEM1In)
          fwd_data3 <= 2'b10;
      else if (fwdaddr3In == WriteAddrWBIn)
            fwd_data3 <= 2'b01;
      else 
         fwd_data3 <= 2'b00;
     
   end 
else if(tmp == 2'b10)
   begin
      if(fwdaddr1In == WriteAddrMEM1In)
          fwd_data1 <= 2'b10;
      else fwd_data1 <= 2'b00;
      if(fwdaddr2In == WriteAddrMEM1In)
          fwd_data2 <= 2'b10;
      else fwd_data2 <= 2'b00;
      if(fwdaddr3In == WriteAddrMEM1In)
          fwd_data3 <= 2'b10;
      else fwd_data3 <= 2'b00;
   end
else if(tmp == 2'b01)
   begin
      if(fwdaddr1In == WriteAddrWBIn)
        fwd_data1 <= 2'b01;
      else fwd_data1 <= 2'b00;
      if(fwdaddr2In == WriteAddrWBIn)
        fwd_data2 <= 2'b01;
      else fwd_data2 <= 2'b00;
      if(fwdaddr3In == WriteAddrWBIn)
        fwd_data3 <= 2'b01;
      else fwd_data3 <= 2'b00;
   end
else
begin
   fwd_data1 <= 2'b00;
   fwd_data2 <= 2'b00;
   fwd_data3 <= 2'b00;
end
end

endmodule


module armreduced(
   input clk,
   input reset,
   output[31:0] pc,
   input[31:0] inst,
   input nIRQ,
   output[3:0] be,
   output[31:0] memaddr,
   output memwrite,
   output memread,
   output[31:0] writedata,
   input[31:0] readdata
   );
   
   wire[31:0] instIF1, instIF2, instID2;
   assign instIF1 = inst;
   wire[31:0] instID;
   wire [2:0] ctr1, ctr2;
   wire[31:0] readdataWB;
   wire[3:0] ReadAddr1, ReadAddr2;
   wire[3:0] WriteAddrID1,WriteAddrID2, WriteAddrEX1, WriteAddrEX2, WriteAddrMEM1, WriteAddrMEM2, WriteAddrWB;
   wire[31:0] ReadData1ID, ReadData1EX;
   wire[31:0] ReadData2ID, ReadData2EX;
   wire[31:0] ReadData3ID, ReadData3EX1, ReadData3EX2;
   wire[31:0] Result; 
   wire[31:0] ExtImmID, ExtImmEX;
   wire[31:0] SrcB;
   wire[31:0] ALUResultEX, ALUResultMEM1, ALUResultMEM2, ALUResultWB;  
   wire[31:0] PCPlus4IF, PCPlus4ID1, PCPlus4ID2, PCPlus4EX; 
   wire[31:0] PCBranchEX, PCBranchMEM;
   wire[31:0] pctmp, NextPC;
   wire[3:0] fwdaddr1,fwdaddr2, fwdaddr3;
   wire[3:0] ALUOpID, ALUOpEX, ALUFlagsEX;
   wire[1:0] RegSrc, RegSrcFin, ImmSrcID;
   wire RegSrc0ID, RegSrc0EX1, RegSrc0EX2, RegSrc0MEM1, RegSrc0MEM2, RegSrc0WB, RegSrc1ID;
   wire PCSrcID, PCSrcEX1, PCSrcEX2, PCSrcMEM;
   wire RegWriteID, RegWriteEX1, RegWriteEX2, RegWriteMEM1, RegWriteMEM2, RegWriteWB;
   wire MemWriteID, MemWriteEX1, MemWriteEX2, MemWriteMEM;
   wire MemtoRegID, MemtoRegEX1, MemtoRegEX2, MemtoRegMEM1, MemtoRegMEM2, MemtoRegWB; 
   wire ALUSrcID, ALUSrcEX;
   wire SvalueID, SvalueEX;
   wire PCenable, IIenable, Ctrlenable, ECC;
   wire [1:0] fwd_data1, fwd_data2, fwd_data3;
   wire WtoPCID, WtoPCWB; // when r15 is written
   assign WtoPCID = (WriteAddrID1 == 4'b1111) ? ((RegWriteID ==1'b1) ? ~RegSrc0ID : 1'b0): 1'b0;
   assign WtoPCWB = (WriteAddrWB == 4'b1111) ? ((RegWriteWB == 1'b1) ? ~RegSrc0WB : 1'b0): 1'b0;
   //cond unit ?????? ??????
   wire [3:0] condID, condEX;
   
   
   //forwarding ?????? load????????? memory?????? ?????? ?????? ????????????. 
   
   wire memreadID, memreadEX1, memreadEX2;
   
   

   
   // instrunc [~:~] ????????? ???????????? ????????? ??? ???????????????
   wire [23:0] ImmID; //instID[23:0]
   wire [1:0] opID;
   wire loadEX;

   assign be = 4'b1111;
   reg[3:0] NZCV;
   assign pc = pctmp;
   assign ReadAddr1 = instID[19:16];
   assign ReadAddr2 = instID[3:0];
   assign WriteAddrID1 = instID[15:12];
   assign RegSrc0ID = RegSrc[0];
   assign RegSrc1ID = RegSrc[1];
   assign RegSrcFin = {RegSrc1ID, RegSrc0WB};
   assign memwrite = MemWriteMEM;
   
    // instrunc [~:~] ????????? ???????????? ????????? ??? ???????????????
   assign ImmID = instID[23:0];
   assign opID = instID[27:26];


  
  //load ????????? ???????????? memtoreg and regwrite??? ???????????? (?????? 1???????????? load??????)
  //??? ?????????
   assign loadEX = memreadEX2;
   
   
      //cond unit ?????? ??????
    assign condID = instID[31:28];
   
   IF_stage _IF_stage( .pcIn(pctmp), .pcBranchIn(PCBranchMEM), .PCSrc(PCSrcMEM), .instIn(instIF1),
   .NextPC(NextPC), .PCPlus4(PCPlus4IF), .instOut(instIF2));
   
   PC_update _PC_update(
   .clk(clk),
   .reset(reset),
   .enable(PCenable),
   .PCIn(NextPC),
   .wdata(Result),
   .WtoPCWB(WtoPCWB),
   .PCOut (pctmp));

   
   RegisterFile _RegisterFile( .clk(clk), .reset(reset), .we(RegWriteWB), .RegSrc(RegSrcFin), .addr1(ReadAddr1), .addr2(ReadAddr2), .addr3(WriteAddrID1),
                        .waddr(WriteAddrWB), .wdata(Result), .pcin(pctmp), .data1(ReadData1ID), .data2(ReadData2ID), .data3(ReadData3ID));
                        
   IF_ID_Register _IF_ID_Register( .clk(clk), .reset(reset), .PCPlus4In(PCPlus4IF), .enable(IIenable), .instIn(instIF2), .PCPlus4Out(PCPlus4ID1), .instOut(instID));
   
   ID_stage _ID_stage(.PCPlus4In(PCPlus4ID1), .waddrIn(WriteAddrID1), .in(ImmID), .ImmSrc(ImmSrcID), .waddrOut(WriteAddrID2), .Ext_immOut(ExtImmID), 
            .PCPlus4Out(PCPlus4ID2), );
   
  ctrlSig _ctrlSig(.enable(CtrlenableID), .op(opID), .funct(instID[25:20]), .ALUOp(ALUOpID), .ImmSrc(ImmSrcID), .RegSrc(RegSrc),  
        .PCSrc(PCSrcID), .RegWrite(RegWriteID), .MemWrite(MemWriteID), .MemtoReg(MemtoRegID), .ALUSrc(ALUSrcID), .Svalue(SvalueID), .memread(memreadID));
 /*
   Decoder _decoder(.op(opID), .funct(functID), .enable(CtrlenableID), .MemtoReg   (MemtoRegID),   .ALUSrc(ALUSrcID), .ImmSrc(ImmSrcID),
      .RegSrc(RegSrc), .ALUOp(ALUOpID), .Svalue(SvalueID));
      
   ConditionalLogic _conditional(
      .op         (opEX),
     .enable     (CtrlenableEX),
      .funct      (functEX),
      .cond      (condEX),
      .Zero      (NZCV[2]),
      .PCSrc      (PCSrcEX),
      .RegWrite   (RegWriteEX),
      .MemWrite   (MemWriteEX));

*/
   ID_EX_Register _ID_EX_Register(.clk(clk), .reset(reset), .addr1In(ReadAddr1), .addr2In(ReadAddr2), .addr3In(WriteAddrID2), .PCPlus4In(PCPlus4ID2), 
         .data1In(ReadData1ID), .data2In(ReadData2ID), .data3In(ReadData3ID), .Ext_immIn(ExtImmID), 
            .waddrIn(WriteAddrID2), .RegSrcIn(RegSrc0ID), 
         .PCSrcIn(PCSrcID), .RegWriteIn(RegWriteID), .MemWriteIn(MemWriteID), .condIn(condID),
         .MemtoRegIn(MemtoRegID), .ALUSrcIn(ALUSrcID), .SvalueIn(SvalueID),
            .ALUOpIn(ALUOpID), .PCplus4Out(PCPlus4EX), .data1Out(ReadData1EX), .data2Out(ReadData2EX), .data3Out(ReadData3EX1), .Ext_immOut(ExtImmEX), .waddrOut(WriteAddrEX1),.RegSrcOut(RegSrc0EX1), 
         .PCSrcOut(PCSrcEX1), .RegWriteOut(RegWriteEX1), .MemWriteOut(MemWriteEX1), .condOut(condEX),
         .MemtoRegOut(MemtoRegEX1), .ALUSrcOut(ALUSrcEX), 
            .SvalueOut(SvalueEX), .ALUOpOut(ALUOpEX), .addr1Out(fwdaddr1), .addr2Out(fwdaddr2), .addr3Out(fwdaddr3),
         .memreadIn(memreadID), .memreadOut(memreadEX1));
 
   Forwarding_Unit _Forwarding_Unit( .RegWriteMEM1In(RegWriteMEM1), .RegWriteWBIn(RegWriteWB), .fwdaddr1In(fwdaddr1), .fwdaddr2In(fwdaddr2), .fwdaddr3In(fwdaddr3), .WriteAddrMEM1In(WriteAddrMEM1), 
                           .WriteAddrWBIn(WriteAddrWB), .fwd_data1(fwd_data1), .fwd_data2(fwd_data2), .fwd_data3(fwd_data3));  
   
 
   EX_stage _EX_stage (.PCPlus4In(PCPlus4EX), .data1In(ReadData1EX), .data2In(ReadData2EX), .MemtoRegIn(MemtoRegEX1),  .data3In(ReadData3EX1), .Ext_immIn(ExtImmEX),    
            .waddrIn(WriteAddrEX1), .ALUOp(ALUOpEX), .RegSrcIn(RegSrc0EX1), .ALUSrc(ALUSrcEX), .PCBranch(PCBranchEX), .fwd_signal1In(fwd_data1), .fwd_signal2In(fwd_data2), .fwd_signal3In(fwd_data3),
         .ResultWB(Result), .ResultMEM(ALUResultMEM1),
            .ALUResult(ALUResultEX), .waddrOut(WriteAddrEX2), .ALUFlags(ALUFlagsEX), .RegSrcOut(RegSrc0EX2), .MemtoRegOut(MemtoRegEX2), .data3Out(ReadData3EX2));
   
   always @ (negedge clk) begin
      if (reset) NZCV = 4'b0000;
      else NZCV = (SvalueEX == 1'b1) ? ALUFlagsEX : NZCV;      
   end   
   
   Cond_Unit _Cond_Unit (.PCSrcIn(PCSrcEX1), .RegWriteIn(RegWriteEX1), .MemWriteIn(MemWriteEX1), .memreadIn(memreadEX1),
                  .PCSrcOut(PCSrcEX2), .RegWriteOut(RegWriteEX2), .MemWriteOut(MemWriteEX2), .memreadOut(memreadEX2),
                  .condIn(condEX), .NZCV(NZCV));
   
   
   //load ????????? ???????????? memtoreg and regwrite??? ???????????? (?????? 1???????????? load??????)
   Hazard_detection_unit _Hazard_detection_unit(
   .opID(opID),
   .PCSrcMEM(PCSrcMEM),
   .loadEX(loadEX),
   .addr1In(ReadAddr1),
   .addr2In(ReadAddr2),
   .addr3In(WriteAddrID1),
   .waddrIn(WriteAddrEX1),
   .ctrIn(ctr1),
   .PCenable(PCenable),
   .IIenable(IIenable),
   .Ctrlenable(Ctrlenable),
   .ctrOut(ctr2),
   .ECC(ECC),
   .WtoPCID(WtoPCID),
   .WtoPCWB(WtoPCWB)
   );
   
   counter _counter(
   .clk(clk),
   .reset(reset),
   .ECC(ECC),
   .ctrIn(ctr2),
   .ctrOut(ctr1)
);

   
   EX_MEM_Register _EX_MEM_Register( .clk(clk), .reset(reset), .PCBranchIn(PCBranchEX), .RegSrcIn(RegSrc0EX2), .ALUResultIn(ALUResultEX), .wdataMIn(ReadData3EX2), .waddrIn(WriteAddrEX2),
         .PCSrcIn(PCSrcEX2), .RegWriteIn(RegWriteEX2),  .MemWriteIn(MemWriteEX2), 
         .MemtoRegIn(MemtoRegEX2), .PCBranchOut(PCBranchMEM), .ALUResultOut(ALUResultMEM1), .wdataMOut(writedata), .memaddr(memaddr),
            .waddrOut(WriteAddrMEM1), .PCSrcOut(PCSrcMEM), .RegWriteOut(RegWriteMEM1), .MemWriteOut(MemWriteMEM), .MemtoRegOut(MemtoRegMEM1), .RegSrcOut(RegSrc0MEM1), .memreadIn(memreadEX2), .memreadOut(memread));


   MEM_stage _MEM_stage ( .RegWriteIn(RegWriteMEM1), .MemtoRegIn(MemtoRegMEM1), .RegSrcIn(RegSrc0MEM1), .ALUResultIn(ALUResultMEM1), .waddrIn(WriteAddrMEM1), 
            .waddrOut(WriteAddrMEM2), .RegWriteOut(RegWriteMEM2),.RegSrcOut(RegSrc0MEM2), .MemtoRegOut(MemtoRegMEM2), .ALUResultOut(ALUResultMEM2));
            

   MEM_WB_Register _MEM_WB_Register( .clk(clk), .reset(reset), .RegSrcIn(RegSrc0MEM2), .readdataIn(readdata), .ALUResultIn(ALUResultMEM2), .waddrIn(WriteAddrMEM2), .MemtoRegIn(MemtoRegMEM2), .RegWriteIn(RegWriteMEM2),
                           .readdataOut(readdataWB), .ALUResultOut(ALUResultWB), .waddrOut(WriteAddrWB), .RegWriteOut(RegWriteWB), .RegSrcOut(RegSrc0WB), .MemtoRegOut(MemtoRegWB));


   WB_stage _WB_stage (.MemtoReg(MemtoRegWB), .readata(readdataWB), .ALUResult(ALUResultWB), 
            .Result(Result));
endmodule

                  
module Cond_Unit (
   input PCSrcIn, RegWriteIn, MemWriteIn, memreadIn,
   input [3:0] condIn, NZCV,
   output reg PCSrcOut, RegWriteOut, MemWriteOut, memreadOut  
);
   reg condEx;
 
   
   always @(*)
   begin
      case(condIn)
         4'b0000: condEx = (NZCV[2] == 1'b1) ? 1'b1 : 1'b0;
         4'b0001: condEx = (NZCV[2] == 1'b0) ? 1'b1 : 1'b0;
         4'b1110: condEx = 1'b1;
       default: condEx = 1'b1;
      endcase
      
      PCSrcOut = PCSrcIn & condEx;
      RegWriteOut = RegWriteIn &condEx;
      MemWriteOut = MemWriteIn & condEx;
	  memreadOut = memreadIn & condEx;
   
   end
endmodule

module Hazard_detection_unit (
   input [1:0] opID,
   input PCSrcMEM,
   input loadEX,
   input [3:0] addr1In,
   input [3:0] addr2In,
   input [3:0] addr3In,
   input [3:0] waddrIn,
   input [2:0] ctrIn,
   input ECC,
   input WtoPCID,
   input WtoPCWB,
   output reg PCenable,
   output reg IIenable,
   output reg Ctrlenable,
   output reg [2:0] ctrOut
   );
   
   always @ (*) 
   begin
   if (ECC == 1'b0) 
      begin
      if (ctrIn == 3'b000) 
         begin
         if (opID == 2'b10)
            begin
            PCenable = 1'b0;
            IIenable = 1'b0;
            Ctrlenable = 1'b1;
            ctrOut = 3'b011;
            end
          else 
            begin
            PCenable = 1'b1;
            IIenable = 1'b1;
            Ctrlenable = 1'b1;
            ctrOut = 3'b000;
            end
         if (WtoPCID == 1'b1) 
            begin
            PCenable = 1'b0;
            IIenable = 1'b0;
            Ctrlenable = 1'b1;
            ctrOut = 3'b100;
            end   

         if ( (loadEX== 1'b1)) 
            begin
            if ((addr1In == waddrIn) || (addr2In == waddrIn) || (addr3In == waddrIn))
               begin
               PCenable = 1'b0;
               IIenable = 1'b0;
               Ctrlenable = 1'b0;
               ctrOut = 3'b000;
               end
            end
        end
        
      else if (ctrIn == 3'b001 )
         begin
         if ((PCSrcMEM|WtoPCWB) == 1'b1) 
            begin
             PCenable = 1'b1;
             ctrOut = ctrIn;
             IIenable = 1'b0;
             Ctrlenable = 1'b0;
            end
         else 
            begin
            PCenable = 1'b0;
            ctrOut = ctrIn;
            IIenable = 1'b0;
            Ctrlenable = 1'b0;
            end
         end 
      else 
         begin //counter ==2 , 3
          PCenable = 1'b0;
          ctrOut = ctrIn;
          IIenable = 1'b0;
          Ctrlenable = 1'b0;
         end
      end
   else begin
      PCenable = 1'b1;
      IIenable = 1'b1;
      Ctrlenable = 1'b0;
      ctrOut = 3'b000;

            
   /*
      if (opID == 2'b10) begin
            PCenable = 1'b1;
           IIenable = 1'b1;
           Ctrlenable = 1'b0;
           ctrOut = 2'b00;
          end
      else begin
          PCenable = 1'b1;
           IIenable = 1'b1;
           Ctrlenable = 1'b1;
           ctrOut = 2'b00;
      end
      */
   end 
end

endmodule   


module counter (
   input clk,
   input reset,
   input [2:0] ctrIn,
   output reg [2:0] ctrOut,
   output reg ECC
);

   
   always @ (negedge clk) begin
   if (reset) begin
      ECC = 1'b0;
     ctrOut = 3'b000;
   end
   else begin
     ECC = 1'b0;
     if (ctrIn == 3'b000)
         ctrOut = 3'b000;
      else begin
         ctrOut = ctrIn-1'b1;
       if (ctrIn == 3'b001)
         ECC = 1'b1;
       else
         ECC = 1'b0;
      end
   end
   end
endmodule