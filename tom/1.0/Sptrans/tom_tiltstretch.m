function o=tom_tiltstretch(i,Tiltaxis,phi_current,phi_previous);

% tom_tiltstretch applies an projective stretch to an image.
%
% SN, 09/03/05
%
%   Copyright (c) 2004
%   TOM toolbox for Electron Tomography
%   Max-Planck-Institute for Biochemistry
%   Dept. Molecular Structural Biology
%   82152 Martinsried, Germany
%   http://www.biochem.mpg.de/tom

AngleFactor=1;
Tiltaxis=Tiltaxis.*pi./180;
phi_current=phi_current.*pi./180;
phi_previous=phi_previous.*pi./180;

SF=cos(phi_previous.*AngleFactor)./cos(phi_current.*AngleFactor);

B0=1+((SF-1).*sin(Tiltaxis).*sin(Tiltaxis))
B1=1+((SF-1).*cos(Tiltaxis).*cos(Tiltaxis))
B2=(1-SF).*cos(Tiltaxis).*sin(Tiltaxis)
dimx=size(i,1);
dimy=size(i,2);
o=zeros(size(i));
o=o+mean2(i);
B3=dimx./2.*(B0+B2-1)
B4=dimy./2.*(B2+B1-1)


for laufx=1:.5:dimx+.499
    for laufy=1:.5:dimy+.499
        newx=round((laufx.*B0)+(B2.*laufy-B3));
        newy=round((laufx.*B2)+(B1.*laufy-B4));
        if(newx>0 && newx<dimx && newy>0 && newy<dimy)
            o(newx,newy)=i(round(laufx),round(laufy));
        end;
    end;
end;


% from Tomosoftware R. Grimm, DM
%
%void AET_WarpImage(image &PrevImage, image CurImage, number MagID)
%// warps an image according to the tilt angle , the tilt angle of the previous image, and the tilt axis direction
%{
%	number SF, Size, HalfSize, CurAngle, PrevAngle;
%	number AA, B0, B1, B2, B3, B4, PrevMean, Warped;
%	image TempImage;

%	if (!GetNumberNote(PrevImage,ImWarp,Warped))			// only warp images that have not been warped already
%	{
%		if (!GetNumberNote(CurImage,ImTiltAngle,CurAngle)) {Result("Tilt angle mising in 'Cur'.\n"); return;}
%		if (!GetNumberNote(PrevImage,ImTiltAngle,PrevAngle)) {Result("Tilt angle mising in 'Prev'.\n"); return;}
%		if (!GetNumberTag(ImShiftPath+MagID+TSAxisAngle,AA)) return;
%		aa = Pi() - AA;
%		SF = cos(PrevAngle*AngleFactor)/cos(CurAngle*AngleFactor);
%//Result("\n> Angles P : "+PrevAngle+"  C : "+CurAngle+"  Factor   "+SF+"\n");
%		B0 = 1 + ((SF - 1)*sin(AA)*sin(AA));
%		B1 = 1 + ((SF - 1)*cos(AA)*cos(AA));
%		B2 = (1-SF)*cos(AA)*sin(AA);
%		GetSize(PrevImage,Size,Size);
%		HalfSize = Size/2;
%		B3 = HalfSize*(B0 + B2 - 1);
%		B4 = HalfSize*(B2 + B1 - 1);
%		PrevImage = CutSoftSquare(PrevImage,10);		// soften the edge by an arbitrary factor
%		TempImage = exprsize(Size,Size,warp(PrevImage,((B0*icol)+(B2*irow)-B3),((B2*icol)+(B1*irow)-B4)));
%		PrevMean = mean(PrevImage);
%		PrevImage = tert((TempImage == 0),PrevMean,TempImage);		// set the unknown pixel to mean, not 0
%		SetNumberNote(PrevImage,ImWarp,1);
%		DeleteImage(TempImage);
%		UpdateImage(PrevImage);
%	}
%}

