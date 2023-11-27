function rsplit=splitlattice(ring0,npts)
elmlength=findspos(ring0,1+length(ring0))/npts;
r2=cellfun(@(a)splitelem(a,elmlength),ring0,'UniformOutput',false);
rsplit=cat(1,r2{:});
end

function newelems=splitelem(elem,elmlength)
if isfield(elem,'Length') && elem.Length > 0
    nslices=ceil(elem.Length/elmlength);
    newelems=atdivelem(elem,ones(1,nslices)./nslices);
else
    newelems={elem};
end
end