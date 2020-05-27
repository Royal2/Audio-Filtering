#include <stdlib.h>
#include <stdio.h>
#include <float.h>
//#include "wave.h"
#include <sndfile.h>
#include <math.h>

#define PI 3.14159265
#define Fs 8000

void SampledSinusoid(float f, float L, float* x);
float iir(float* x);
float* y;   //global

int main(int argc, char *argv[])
{

	//Require 2 arguments: input file and output file
	if(argc < 2)
	{
		printf("Not enough arguments \n");
		return -1;
	}
	SF_INFO sndInfoOut;
	sndInfoOut.format = SF_FORMAT_WAV | SF_FORMAT_PCM_16;   //WAV file
	sndInfoOut.channels = 1;
	sndInfoOut.samplerate = Fs;
	SNDFILE *sndFileOut = sf_open(argv[1], SFM_WRITE, &sndInfoOut);
	
	//Insert your code here =====================
    int f_melody[8]={440,495,550,587,660,733,825,0};//last for nu
    int f_chorus[7]={206,220,248,275,293,330,367};
    //allocating memory for song array
    int theNumOfSamples = 32*4000;  //128000 samples in song
    float* x = malloc(sizeof(float)*theNumOfSamples); // sum
    float* x1 = malloc(sizeof(float)*theNumOfSamples);// melody
    float* x2 = malloc(sizeof(float)*theNumOfSamples);// chorus
    //generating song
    int song_melody[32]={1,8,1,8,5,8,5,8,6,8,6,8,5,8,8,8,4,8,4,8,3,8,3,8,2,8,2,8,1,8,8,8};
    int song_chorus[32]={1,5,3,5,1,5,3,5,1,6,4,6,1,5,3,5,7,5,4,5,1,5,2,5,7,5,4,5,1,5,3,5};
    //float x_melody[theNumOfSamples]={0};
    //float x_chorus[theNumOfSamples]={0};
    for(int i=0;i<32;i++){ //iterate 32 times, sizeof(song_melody) was giving 128
        SampledSinusoid((float)f_melody[song_melody[i]],(float)0.5, x1+(i*4000));//L=0.5 seconds
    }
    for(int i=0;i<32;i++){ //iterate 32 times, sizeof(song_melody) was giving 128
        SampledSinusoid((float)f_chorus[song_chorus[i]],(float)0.5, x2+(i*4000));//L=0.5 seconds
    }
    //mixing the two signals
    for(int i=0;i<theNumOfSamples;i++){
        *(x+i)=(*(x1+i)*0.6)+(*(x2+i)*0.4);//element by element
    }
    //filtering
    y = malloc(sizeof(float)*theNumOfSamples); //filter output, global
    for(int i=1;i<=4;i++){
        *(x-i)=0;   //causal signal, x[n-1,...,n-4]=0
        *(y-i)=0;   //causal signal, y[n-1,...,n-4]=0
    }
    for(int i=0;i<theNumOfSamples;i++){
        *(y+i)=iir((x+i));
    }
    // write data to file
	for(int i=0; i < theNumOfSamples; i++)
	{
        //uncomment one at a time.
		//sf_writef_float(sndFileOut, x+i, 1);  //unfiltered song
        sf_writef_float(sndFileOut, y+i, 1);    //filtered song
	}
    //end ========================================
    
	sf_write_sync(sndFileOut);
	sf_close(sndFileOut);
	free(x);
	free(x1);
	free(x2);

	return 1;
}

void SampledSinusoid(float f, float L, float* x)
{
    int samples=Fs*L;
    float t[samples];  //array size of 4000, given L=0.5
    t[0]=0.0; //initialize first element
    for(int i=1;i<samples;i++){    //start indexing from 1
        t[i]=(float)1/Fs+t[i-1]; //increment by steps of 1/Fs
    }
    //t=[0.000000,0.499862], with 0.000125 step
    //float tone[samples];
    for(int i=0;i<samples;i++){
        //tone[i]=sin(2*PI*f*t[i]); //expecting t=[0,0.4999]
        *(x+i)=sin(2*PI*f*t[i]);    //assign to value of pointer
    }
    //x is well defined from [0,3999]
    
    //x=&tone[0];  //assigning pointer to address of first tone element
    /*
    printf("samples is %d, 1/Fs is %lf, t[0] is %lf, t[1] is %lf and t[end] is %lf \n", samples, step, t[0], t[1], t[samples-1]);
    printf("x[0] is %lf, x[1] is %lf, x[2] is %lf, x[3998] is %lf, x[3999] is %lf, x[4000] is %lf \n",x[0],x[1],x[2],x[samples-2],x[samples-1],x[samples]);
    */
}

float iir(float* x)
{
    for(int i=0;i<128000;i++){
        return (*(x+i)*0.62477732)+(*(x+i-1)*-2.44497)+(*(x+i-2)*3.64114)+(*(x+i-3)*-2.444978)+(*(x+i-4)*0.62477732)-(*(y+i-1)*-3.1820023)-(*(y+i-2)*3.9741082)-(*(y+i-3)*-2.293354)-(*(y+i-4)*0.52460587);
    }
}
