function vals2 = normalizevals(vals)
% normalise values to be between 0 and 1

mn = min(min(vals),[],2);
mx = max(max(vals),[],2);
vals2 = bsxfun(@rdivide,bsxfun(@minus,vals,mn),mx-mn);