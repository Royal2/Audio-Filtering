function [y_out] = IIR_filter_h(x_in)
%IIR Filter, h
%filter specs
    %b0=1;
    b1=-3.1820023;
    b2=3.9741082;
    b3=-2.293354;
    b4=0.52460587;
    a0=0.62477732;
    a1=-2.444978;
    a2=3.64114;
    a3=-2.444978;
    a4=0.62477732;
    order=4;    %fourth order filter

    b=[b1 b2 b3 b4];    %denomenator of H(s)
    a=[a0 a1 a2 a3 a4]; %numerator of H(s)

    len=size(x_in,2);  %length = columns of x_in
    y=zeros(1,len+order);

    %define first 4 terms
    %pad zeros in beginning of signal for causality
    %y[1]=a[1]*x[1];
    %y[2]=a[1]*x[2]+a[2]*x[1]-b[2]*y[1];
    %and so on

    x=[zeros(1,order),x_in]; %zero padding

    for i=order+1:1:(len+order)   %offsetting indexing, start idxing at 5
        y(i)=a(1)*x(i)+a(2)*x(i-1)+a(3)*x(i-2)+a(4)*x(i-3)+a(5)*x(i-4)-b(1)*y(i-1)-b(2)*y(i-2)-b(3)*y(i-3)-b(4)*y(i-4);
    end
    y_out=y(order+1:1:end); %order+1, inclusive
end