function motl_out = Pent_extr (motl, particlefile, vertex_outfile, ps, radius, iclass, cubesize)
% motl_out = Pent_extr (motl, particlefile, vertex_outfile, ps, radius, iclass,cubesize)
%
% This function extracts the Vertexes of ikosaedreal capsid single
% particles and writes them to harddisk. The input capsids should be aligned 
% with av3_scan_fast_iko to the i90 orientation. The orientation of the 
% Vertexes is approximated with a sherical normal vector model (see normalvec.m) 
% and saved in the motl_out array. The original particle number is stored 
% in column 6.
%
% motl_out       : motl of Vertexes
% motl           : input motl of oriented capsids
% particlefile   : capsid particles (_No.em is assumed)
% vertex_outfile : filename for output vertexes (_No.em is added)
% ps             : pixelsize of given capsid in nm
% radius         : of capsid in nm (eg. 130 for HSV)
% iclass         : class of interest in motl
% cubesize       : desired size of ouput datacube (no edge check implemented)
%
% eg.:
% motl_out = Pent_extr (motl2_test, 'test2_par', 'vertexes/vertex',44, 1, 64);
%
% KG+MB 24/04/06, tested

load VertexCoor.asc
radius = (radius*ps)/2;
PentCoorScaled = VertexCoor.* radius;
cs = cubesize;
idx = find(motl(20,:)==iclass);
motl_out = zeros(20,size(idx,2)*12);
disp(['Number of vertexes to extract is : ' num2str(size(idx,2)*12)]);
for i = 1:size(motl,2),
    if motl(20,i)== iclass,
        phi = motl(17,i);
        psi = motl(18,i);
        the = motl(19,i);
        shift = motl(11:13,i)';
        par = tom_emread([particlefile '_' num2str(motl(4,i)) '.em']);par = par.Value;
        for j = 1:size(PentCoorScaled,1),
            vec = tom_pointrotate(PentCoorScaled(j,1:3),phi,psi,the);
            Posi = floor(shift + vec + [floor(size(par,1)/2+1) floor(size(par,1)/2+1) floor(size(par,1)/2+1)]);
            vertex = par( Posi(1)-cs/2+1:Posi(1)+cs/2, Posi(2)-cs/2+1:Posi(2)+cs/2, Posi(3)-cs/2+1:Posi(3)+cs/2 );
            motl_out(:,((i-1)*12)+j) = motl(:,i);
            motl_out(8:10,((i-1)*12)+j)= Posi;
            motl_out(4, (((i-1)*12)+j) ) = ((i-1)*12)+j;
            motl_out(6, (((i-1)*12)+j) ) = motl(4,1);
            tom_emwrite([vertex_outfile '_' num2str(((i-1)*12)+j) '.em'],vertex)
            % begin orientation correction
            tmp = (Posi - ([floor(size(par,1)/2+1) floor(size(par,1)/2+1) floor(size(par,1)/2+1)] + shift));
            x = tmp(1); y = tmp(2); z = tmp(3);
            THETA= 180/pi*atan2(sqrt(x.^2+y.^2),z); %theta
            PSI  = 90+180/pi*atan2(y,x); %psi
            motl_out(18,(((i-1)*12)+j))=PSI;
            motl_out(19,(((i-1)*12)+j))=THETA;
            % end orientation correction
            %vertex_rot = tom_rotate(vertex,[-motl_out(18,(((i-1)*12)+j)) -motl_out(17,(((i-1)*12)+j)) -motl_out(19,(((i-1)*12)+j))],'linear');
            %figure(1);tom_dspcub(vertex);figure(2);tom_dspcub(vertex_rot);
            %waitforbuttonpress;disp([num2str(j) ' ' num2str(Posi(1)) ' ' num2str(Posi(2)) ' ' num2str(Posi(3)) ' ' ])
        end
    end
end
motl_out(11:16,:)=0;motl_out(1,:)=1;% delete original shifts and set CCC to 1
disp('Done.')
