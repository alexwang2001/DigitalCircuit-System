module sorting(val, sort_out);
input wire [4:0] val [5:0];
output logic [4:0] sort_out [5:0];
logic [4:0] sort_lay [5:0][7:0];
parameter N = 4;

assign sort_lay[0][0] = val[0];
assign sort_lay[1][0] = val[1];
assign sort_lay[2][0] = val[2];
assign sort_lay[3][0] = val[3];
assign sort_lay[4][0] = val[4];
assign sort_lay[5][0] = val[5];
assign sort_out[0] = sort_lay[0][N]; 
assign sort_out[1] = sort_lay[1][N]; 
assign sort_out[2] = sort_lay[2][N]; 
assign sort_out[3] = sort_lay[3][N]; 
assign sort_out[4] = sort_lay[4][N]; 
assign sort_out[5] = sort_lay[5][N]; 
//layer1
Sort3 sort3_1(sort_lay[0][0],sort_lay[1][0],sort_lay[2][0],sort_lay[0][1],sort_lay[1][1],sort_lay[2][1]);
Sort3 sort3_2(sort_lay[3][0],sort_lay[4][0],sort_lay[5][0],sort_lay[3][1],sort_lay[4][1],sort_lay[5][1]);
//layer2
Sort2 sort2_1(sort_lay[0][1],sort_lay[3][1],sort_lay[0][2],sort_lay[3][2]);
Sort2 sort2_2(sort_lay[1][1],sort_lay[4][1],sort_lay[1][2],sort_lay[4][2]);
Sort2 sort2_3(sort_lay[2][1],sort_lay[5][1],sort_lay[2][2],sort_lay[5][2]);
//layer3
Sort2 sort2_4(sort_lay[1][2],sort_lay[3][2],sort_lay[1][3],sort_lay[3][3]);
Sort2R sort2_5(sort_lay[2][2],sort_lay[4][2],sort_lay[2][3],sort_lay[4][3]);
//layer4
Sort2 sort2_6(sort_lay[2][3],sort_lay[3][3],sort_lay[2][4],sort_lay[3][4]);
assign {sort_lay[0][4],sort_lay[1][4],sort_lay[4][4],sort_lay[5][4]} = {sort_lay[0][2],sort_lay[1][3],sort_lay[4][3],sort_lay[5][2]};
/*
//layer1
assign {sort_lay[0][1],sort_lay[1][1]} = sort_lay[0][0]>sort_lay[1][0] ? {sort_lay[0][0],sort_lay[1][0]}:{sort_lay[1][0],sort_lay[0][0]};
assign {sort_lay[3][1],sort_lay[4][1]} = sort_lay[3][0]>sort_lay[4][0] ? {sort_lay[3][0],sort_lay[4][0]}:{sort_lay[4][0],sort_lay[3][0]};
assign {sort_lay[2][1],sort_lay[5][1]} = {sort_lay[2][0],sort_lay[5][0]};
//layer2
assign {sort_lay[1][2],sort_lay[2][2]} = sort_lay[1][1]>sort_lay[2][1] ? {sort_lay[1][1],sort_lay[2][1]}:{sort_lay[2][1],sort_lay[1][1]};
assign {sort_lay[4][2],sort_lay[5][2]} = sort_lay[4][1]>sort_lay[5][1] ? {sort_lay[4][1],sort_lay[5][1]}:{sort_lay[5][1],sort_lay[4][1]};
assign {sort_lay[0][2],sort_lay[3][2]} = {sort_lay[0][1],sort_lay[3][1]};
//layer3
assign {sort_lay[0][3],sort_lay[1][3]} = sort_lay[0][2]>sort_lay[1][2] ? {sort_lay[0][2],sort_lay[1][2]}:{sort_lay[1][2],sort_lay[0][2]};
assign {sort_lay[3][3],sort_lay[4][3]} = sort_lay[3][2]>sort_lay[4][2] ? {sort_lay[3][2],sort_lay[4][2]}:{sort_lay[4][2],sort_lay[3][2]};
assign {sort_lay[2][3],sort_lay[5][3]} = {sort_lay[2][2],sort_lay[5][2]};
//layer4,5
genvar i;
generate
    for(i=0; i<=2; i=i+1)
        assign {sort_lay[i][4],sort_lay[i+3][4]} = sort_lay[i][3]>sort_lay[i+3][3] ? {sort_lay[i][3],sort_lay[i+3][3]}:{sort_lay[i+3][3],sort_lay[i][3]};
    for(i=1; i<=2; i=i+1)
        assign {sort_lay[i][5],sort_lay[i+2][5]} = sort_lay[i][4]>sort_lay[i+2][4] ? {sort_lay[i][4],sort_lay[i+2][4]}:{sort_lay[i+2][4],sort_lay[i][4]};
endgenerate
// layer6
assign {sort_lay[2][6],sort_lay[3][6]} = sort_lay[2][5]>sort_lay[3][5] ? {sort_lay[2][5],sort_lay[3][5]}:{sort_lay[3][5],sort_lay[2][5]};
assign sort_lay[0][6] = sort_lay[0][4];
assign sort_lay[1][6] = sort_lay[1][5];
assign sort_lay[4][6] = sort_lay[4][5];
assign sort_lay[5][6] = sort_lay[5][4];
*/
/*
genvar i;
generate
    //lay1
    for(i=0; i<=5; i=i+2)
        assign {sort_lay[i][1],sort_lay[i+1][1]} = sort_lay[i][0]>sort_lay[i+1][0] ? {sort_lay[i][0],sort_lay[i+1][0]}:{sort_lay[i+1][0],sort_lay[i][0]};
    //lay2
    assign {sort_lay[2][2],sort_lay[4][2]} = sort_lay[2][1]>sort_lay[4][1] ? {sort_lay[2][1],sort_lay[4][1]}:{sort_lay[4][1],sort_lay[2][1]};
    assign sort_lay[0][2] = sort_lay[0][1];
    assign sort_lay[1][2] = sort_lay[1][1];
    assign sort_lay[3][2] = sort_lay[3][1];
    assign sort_lay[5][2] = sort_lay[5][1];
    //lay3
    assign {sort_lay[0][3],sort_lay[2][3]} = sort_lay[0][2]>sort_lay[2][2] ? {sort_lay[0][2],sort_lay[2][2]}:{sort_lay[2][2],sort_lay[0][2]};
    assign {sort_lay[1][3],sort_lay[3][3]} = sort_lay[1][2]>sort_lay[3][2] ? {sort_lay[1][2],sort_lay[3][2]}:{sort_lay[3][2],sort_lay[1][2]};
    assign sort_lay[4][3] = sort_lay[4][2];
    assign sort_lay[5][3] = sort_lay[5][2];
    //lay4
    assign {sort_lay[3][4],sort_lay[5][4]} = sort_lay[3][3] > sort_lay[5][3] ? {sort_lay[3][3],sort_lay[5][3]}:{sort_lay[5][3],sort_lay[3][3]};
    assign sort_lay[1][4] = sort_lay[1][3];
    assign sort_lay[2][4] = sort_lay[2][3];
    assign sort_lay[4][4] = sort_lay[4][3];
    //lay5
    for(i=1; i<=2; i=i+1)
        assign {sort_lay[i][5],sort_lay[i+2][5]} = sort_lay[i][4] > sort_lay[i+2][4] ? {sort_lay[i][4],sort_lay[i+2][4]}:{sort_lay[i+2][4],sort_lay[i][4]};
    //lay6
    for(i=1; i<=3; i=i+2)
        assign {sort_lay[i][6],sort_lay[i+1][6]} = sort_lay[i][5]>sort_lay[i+1][5] ? {sort_lay[i][5],sort_lay[i+1][5]}:{sort_lay[i+1][5],sort_lay[i][5]};
    //lay7
    assign {sort_lay[2][7],sort_lay[3][7]} = sort_lay[2][6]>sort_lay[3][6] ? {sort_lay[2][6],sort_lay[3][6]}:{sort_lay[3][6],sort_lay[2][6]};
    assign sort_lay[0][7] = sort_lay[0][3];
    assign sort_lay[1][7] = sort_lay[1][6];
    assign sort_lay[4][7] = sort_lay[4][6];
    assign sort_lay[5][7] = sort_lay[5][4];
endgenerate
*/
/*
genvar i,j;
generate
    for(i=0; i<=5; i=i+2)
        assign {sort_lay0[i],sort_lay0[i+1]} = val[i]>val[i+1] ? {val[i],val[i+1]} : {val[i+1],val[i]};
    for(i=1; i<=4; i=i+2)
        assign {sort_lay1[i],sort_lay1[i+1]} = sort_lay0[i]>sort_lay0[i+1] ? {sort_lay0[i],sort_lay0[i+1]} : {sort_lay0[i+1],sort_lay0[i]};
    for(i=0; i<=5; i=i+2)
        assign {sort_lay2[i],sort_lay2[i+1]} = sort_lay1[i]>sort_lay1[i+1] ? {sort_lay1[i],sort_lay1[i+1]} : {sort_lay1[i+1],sort_lay1[i]};
    for(i=1; i<=4; i=i+2)
        assign {sort_lay3[i],sort_lay3[i+1]} = sort_lay2[i]>sort_lay2[i+1] ? {sort_lay2[i],sort_lay2[i+1]} : {sort_lay2[i+1],sort_lay2[i]};
    for(i=0; i<=5; i=i+2)
        assign {sort_out[i],sort_out[i+1]} = sort_lay3[i]>sort_lay3[i+1] ? {sort_lay3[i],sort_lay3[i+1]} : {sort_lay3[i+1],sort_lay3[i]};
*/
/*
    for(j=0; j<5; j=j+1) begin
        if(j%2 == 0)
            for(i=0; i<=5; i=i+2)
                assign {sort_lay[i][j+1],sort_lay[i+1][j+1]} = sort_lay[i][j]>sort_lay[i+1][j] ? {sort_lay[i][j],sort_lay[i+1][j]} : {sort_lay[i+1][j],sort_lay[i][j]};
        else begin
            for(i=1; i<=4; i=i+2)
                assign {sort_lay[i][j+1],sort_lay[i+1][j+1]} = sort_lay[i][j]>sort_lay[i+1][j] ? {sort_lay[i][j],sort_lay[i+1][j]} : {sort_lay[i+1][j],sort_lay[i][j]};
            assign {sort_lay[0][j+1],sort_lay[5][j+1]} = sort_lay[0][j]>sort_lay[5][j] ? {sort_lay[0][j],sort_lay[5][j]} : {sort_lay[5][j],sort_lay[0][j]};
        end
    end
    
endgenerate
*/
//assign {sort_lay1[0],sort_lay1[5]} = sort_lay0[0]>sort_lay0[5]? {sort_lay0[0],sort_lay0[5]}:{sort_lay0[5],sort_lay0[0]};
//assign {sort_lay3[0],sort_lay3[5]} = sort_lay2[0]>sort_lay2[5]? {sort_lay2[0],sort_lay2[5]}:{sort_lay2[5],sort_lay2[0]};
endmodule


module Sort3(in0, in1, in2, out0, out1, out2);
    input [4:0] in0, in1, in2;
    output logic [4:0] out0, out1, out2;
    logic [4:0] lay[2:0][1:0];

    Sort2R sort2_1(in0, in1, lay[0][0], lay[1][0]);
    Sort2 sort2_2(lay[1][0], in2, lay[1][1], out2);
    Sort2 sort2_3(lay[0][1], lay[1][1], out0, out1);
    assign lay[0][1] = lay[0][0];
endmodule

module Sort2(in0, in1, out0, out1);
    input [4:0] in0, in1;
    output logic [4:0] out0, out1;
    assign {out0,out1} = in0 > in1? {in0,in1} : {in1,in0};
endmodule

module Sort2R(in0, in1, out0, out1);
    input [4:0] in0, in1;
    output logic [4:0] out0, out1;
    assign {out1,out0} = in1 > in0? {in0,in1} : {in1,in0};
endmodule