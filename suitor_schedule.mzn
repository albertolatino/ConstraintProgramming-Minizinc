
% scheduling suitors
enum SUITOR;
SUITOR: LiuBei; % which suitor is LiuBei
int: n; % number of meetings
set of int: MEETING = 1..n;
array[MEETING] of SUITOR: suitor;

enum ROOM = { Red, Gold, Blue };
array[SUITOR,ROOM] of int: mintime;
array[SUITOR,ROOM] of int: maxtime;
constraint forall(s in SUITOR, r in ROOM)
                 (assert(mintime[s,r] >= 1 /\ maxtime[s,r] >= mintime[s,r],
                  "error in mintime/maxtime at [\(s),\(r)]\n"));

array[ROOM,ROOM] of int: move;
constraint forall(r in ROOM)(assert(move[r,r] = 0,"move[\(r),\(r)] != 0\n"));

int: ndays; % number of days
set of int: DAY = 1..ndays;
int: earliest; % time for earliest meeting start
int: latest;  % time for end of latest meeting

int: lessontime; % time for kung fu lesson;
int: minsep;     % minimum time between consecutive kung fu lessons

array[ROOM] of int: usedstart;  % time others use each room each day
array[ROOM] of int: useddur;    % durations of others use

enum STAGE = {A,B,C};
STAGE: stage;

set of int: TIME = 0..24*ndays;

array[MEETING] of var TIME: start;
array[MEETING] of var TIME: dur;    % duration in false schedule
array[MEETING] of var ROOM: room;
set of int: KUNGFU = 1..n;
array[KUNGFU] of var int: kungfu;  %start time for each lesson
   % unused lessons have start times after 24*ndays




include "disjunctive.mzn";

%%MEETINGS CANNOT OVERLAP
constraint disjunctive(start, dur);

%%ROOMS CANNOT BE USED WHEN ARE BUSY 
constraint forall(m in MEETING)((start[m] + dur[m]) mod 24 <= usedstart[room[m]] \/ (start[m]) mod 24 >= (usedstart[room[m]] + useddur[room[m]]));

%%Constraint on the duration of meetings, considering also the presence of lessons
constraint forall(m in MEETING) (
    dur[m] - lesson[m]*lessontime >= mintime[suitor[m], room[m]] /\
    dur[m] <= maxtime[suitor[m], room[m]]
);

%%MEETINGS MUST START FROM EARLIEST AND END AT MOST AT LATEST
constraint forall(m in MEETING) (start[m] mod 24 >= earliest /\  start[m] mod 24 <= latest /\ (start[m]+dur[m]) mod 24 <=latest /\ (start[m]+dur[m]) mod 24 >= earliest );

%Visits last at most to n_days*24
constraint forall(m in MEETING) (start[m]+dur[m] <= 24*ndays);

%%kungfu lessons greater than 24*n_days 
constraint stage in {A,B} -> forall (k in KUNGFU) (kungfu[k] >= 24*ndays);


%%STAGE B constraints

constraint forall(m1,m2 in MEETING where m1 < m2)(move[room[m1],room[m2]] > 0 -> start[m2] >= start[m1] + dur[m1] + move[room[m1],room[m2]]);

%%STAGE C constraints REMEMBER TO ADD IMPLICATION


%%Map meetings to Kungfu

array[KUNGFU] of var 0..n: kungfuToMeeting;

array[MEETING] of var 0..1: lesson;

constraint stage in {A,B} -> forall(m in MEETING)(lesson[m]=0);

constraint stage in {A,B} -> forall(k in KUNGFU)(kungfuToMeeting[k]=0);

%%Minimum separation between kungfu lessons
constraint forall(k in 1..n-1) ( kungfu[k] + minsep + lessontime <= kungfu[k+1]);

constraint stage in {C} -> forall(k in KUNGFU where kungfu[k] <=24*ndays)(exists(m in MEETING)(kungfu[k] + lessontime = start[m] + dur[m] /\ kungfuToMeeting[k] = m));

constraint stage in {C} -> forall(m in MEETING)(if exists(k in KUNGFU)(kungfuToMeeting[k]=m) then lesson[m]=1 else lesson[m]=0 endif);

%%Meetings' precedence
constraint forall(s in SUITOR) (forall(m1, m2 in MEETING where suitor[m1] = s /\ suitor[m2] = s /\ m1 < m2)(start[m1] < start[m2] ));

%%The start of the lessons is greater than 0
constraint forall(k in KUNGFU) (kungfu[k] > 0 );


var int: kungfu_hours;

%Define time spend by LiuBei
var int : LiuBei_time;
constraint LiuBei_time = sum(m in MEETING where suitor[m] = LiuBei) (dur[m]-lesson[m]*lessontime);

constraint kungfu_hours = sum(k in KUNGFU where kungfu[k] < 24*ndays) (1);

constraint stage in {A,B} -> kungfu_hours = 0;
                                          
solve maximize 100*kungfu_hours + LiuBei_time;
