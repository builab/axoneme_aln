for i=1:40,
    if i < 10,
        par=tom_mrcread(['highf_00' num2str(i) '.mrc']);
    else par=tom_mrcread(['highf_0' num2str(i) '.mrc']);
    end
    [mean max min std] = tom_dev(par.Value);
    par = (par.Value-mean)./std;
    tom_dev(par);
    tom_emwrite(['high_' num2str(i) '.em'],par);
end
    