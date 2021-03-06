filename master 'C:\SASProject\Master.csv';
filename newform 'C:\SASProject\NewForms.csv';
filename assign 'C:\SASProject\Assignments.csv';
filename correct 'C:\SASProject\Corrections.csv';

/*import Master data*/
data master_n;

infile master firstobs=2 dsd; /*get rid of the first row in the orginal data */
retain Consultant ProjNum Date Hours Stage Complete; /*Keep the column order*/
length Date $10;
input Consultant $ ProjNum Date Hours Stage Complete;
run;

/*import NewForm data */
data newform_n;
infile newform firstobs=2 dsd;
retain ProjNum Date Hours Stage Complete;
length Date $10;
input ProjNum Date Hours Stage Complete;
run;

/*import Assignment data */
data assign_n;
infile assign firstobs=2 dsd;
input Consultant $ ProjNum;
run;

/*import Correction */
data correct_n;
infile correct firstobs=2 dsd;
length Date $10;
input ProjNum Date $ Hours Stage;
run;


/*stack newform_n and master_n */
data stack_MN;
set master_n newform_n;
run;

/*After stacking, the additional ProjNum from newform will not have corresponding consultant name. The following codes serve as a
a way to fill in the missing consultant name */

data stack_fill;
set stack_MN;
retain X; /*keep the last non-missing value in memory*/
if not missing (Consultant) Then X = Consultant; /*fills the new variable with non-missing value */
Consultant = X;
run;

/* merge stack_fill with assign_n */

/** sort assign_n **/
proc sort data=assign_n;
by ProjNum;
run;

/** sort stack_fill **/
proc sort data=stack_fill;
by ProjNum;
run;

/** merge **/
data merge_a;
merge assign_n stack_fill;
by ProjNum;
run;

/* update merge_a with correct_n */

/**sort correct_n **/
proc sort data= correct_n;
by ProjNum Date;
run;

/**sort merge_a **/
proc sort data= merge_a;
by ProjNum Date;
run;

data new_master;
update merge_a correct_n; /*Update merge_a using correct_n by referring to both ProjNum and Date*/
by ProjNum Date;
run;

proc sort data= new_master;
by ProjNum Date;
run;
