% Function to check priority
function [isPrior] = checkPriority(clientID, map)
   isPrior = true;
   keysArr = keys(map);
   if any(cell2mat(keysArr) < clientID)
        isPrior = false;  % Return false if any key is less than the clientId
   end
end