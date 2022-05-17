% Preparing a banquet in the least time
enum COOK; % the set of cooks available
enum DISH; % the set of all dishes to prepare
int: no_tasks; % total number of tasks
set of int: TASK = 1..no_tasks;
array[DISH] of set of TASK: steps; % steps to making a dish
array[TASK, COOK] of int: time; % amount of time to complete task by cook

int: maxt = sum(array1d(time));
set of int: TIME = 0..maxt;
array[TASK] of var TIME:    s;  % start time for task
array[TASK] of var COOK:    c;  % cook for task
var TIME: obj;

include "globals.mzn";

%Steps done by a cook do not overlap
constraint forall(cook in COOK)(disjunctive([s[t] | t in TASK where c[t] = cook], 
                                            [time[t, cook] | t in TASK]));

% steps finished in certain order
constraint forall(d in DISH)(
             forall(i in 1..card(steps[d])-1)(let {var int:t1 = steps[d][i]; var int:t2 = steps[d][i+1];} in s[t2] >= s[t1] + time[t1,c[t1]]));

%%Task is done by cook if cook can complete the task
constraint forall(t in TASK)(time[t,c[t]]>0);

constraint obj = max([s[t]+time[t,c[t]]| t in TASK]);


%ann: varsel= input_order;
ann: varsel= first_fail;
%ann: varsel= smallest;
%ann: varsel= largest;
%ann: varsel= dom_w_deg;



%ann: valsel = indomain_min;
%ann: valsel = indomain_max;
%ann: valsel = indomain_median;
%ann: valsel = indomain_random;
%ann: valsel = outdomain_min;
%ann: valsel = outdomain_max;
ann: valsel = indomain_random;
%ann: valsel = indomain_split;
%ann: valsel = indomain_reverse_split;

%ann: restart = restart_luby(5);
%ann: restart =restart_geometric(4,100);
%ann: restart = restart_linear(10); 
ann: restart =restart_constant(10);



ann: search;   

ann: search1 = int_search(c, varsel, valsel,complete);
          
search = search1;     

solve :: search
      :: restart
      minimize obj;
      