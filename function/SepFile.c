#include "mex.h"
#include "matrix.h"
#include <string.h>
#include <stdio.h>

void separatefile(char * Ofile, char ** Nfile, int PageSize, int Pages)
{
	FILE * pofile;
	FILE * pnfile;
	char str[4000];
	char debugstr[140];
	int i=0,j=0;
	int lines = 0,curline = 0;

	pofile = fopen( Ofile, "r+t");
	lines = PageSize / 5;
	for (j=0;j<Pages;j++)
	{
		sprintf(debugstr,"Create Separated File: %s\n",Nfile[j]);
		mexPrintf(debugstr);

		pnfile = fopen( Nfile[j], "w+t");
		while (!feof(pofile)){
			fgets(str,4000,pofile);
			fputs(str,pnfile);
			fgets(str,4000,pofile);
			fputs(str,pnfile);
			fgets(str,4000,pofile);
			fputs(str,pnfile);
			fgets(str,4000,pofile);
			fputs(str,pnfile);
			fgets(str,4000,pofile);
			fputs(str,pnfile);
			curline ++;
			if (curline == lines)
			{
				curline = 0;
				break;
			}
		}
		fclose(pnfile);
	}

	fclose(pofile);	
	return;
}

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  double *pr;
  int PageSize;
  int m,n,i;
  char debugstr[140];
  char * Ofile;
  char ** Nfile;
  mxArray * parr;

  int buflen;


  /*  Check for proper number of arguments. */
  /* NOTE: You do not need an else statement when using 
     mexErrMsgTxt within an if statement. It will never 
     get to the else statement if mexErrMsgTxt is executed. 
     (mexErrMsgTxt breaks you out of the MEX-file.) 
  */ 
  if (nrhs != 3) 
    mexErrMsgTxt("Three input required.");

  /* Create a pointer to the input matrix y. */

  Ofile = mxArrayToString(prhs[0]);
  n = mxGetN(prhs[0]);
  m = mxGetM(prhs[0]);
  sprintf(debugstr,"Original File : %s\n",Ofile);
  mexPrintf(debugstr);

  
  //pr = mxGetPr(prhs[0]); 
  n = mxGetN(prhs[1]);
  m = mxGetM(prhs[1]);
  //buflen = (mxGetM(prhs[1]) * mxGetN(prhs[1]) * sizeof(mxChar)) + 1;
  //Nfile = mxCalloc(buflen, sizeof(mxChar));
 
  // read the cell 
  Nfile = (char **)calloc(n,sizeof(char *));
  sprintf(debugstr,"Pages: %d\n",n);
  mexPrintf(debugstr);
  
  for (i=0;i<n;i++)
  {
	parr = mxGetCell(prhs[1],i);
	Nfile[i] = (char *)calloc(200,sizeof(char));
	memset(Nfile[i],0x0,200);
	Nfile[i] = mxArrayToString(parr);
	///*sprintf(debugstr,"%d,%d : %s",m,n,Nfile[i]);
	//mexWarnMsgTxt(debugstr);*/
  }
  pr = mxGetPr(prhs[2]);
  PageSize = *pr;
  sprintf(debugstr,"PageSize : %d\n", PageSize);
  mexPrintf(debugstr);

  //Nfile = mxGetPr(prhs[1]);
  //n = mxGetN(prhs[1]);
  separatefile(Ofile,Nfile,PageSize,n);
}

