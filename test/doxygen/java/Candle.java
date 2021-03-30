package gehtsoft.pricearchive.client;


public class Candle 
{
    private double mOpen;
    private double mHigh;
    private double mLow;
    private double mClose;
    private double mVolume;

    Candle(double open, double high, double low, double close, double volume)
    {
        mOpen = open;
        mHigh = high;
        mLow = low;
        mClose = close;
        mVolume = volume;
    }

    public double getOpen()
    {
        return mOpen;
    }

    public double getHigh()
    {
        return mHigh;
    }

    public double getLow()
    {
        return mLow;
    }

    public double getClose()
    {
        return mClose;
    }

    public double getVolume()
    {
        return mVolume;
    }   

    public void updateByTick(double value, double volume)
    {
        mClose = value;
        if (value > mHigh)
            mHigh = value;
        if (value < mLow)
            mLow = value;
        mVolume += volume;
    }

    public void updateByCandle(double high, double low, double close, double volume)
    {
        mClose = close;
        if (high > mHigh)
            mHigh = high;
        if (low < mLow)
            mLow = low;
        mVolume += volume;
    }

    public void updateByCandle(Candle candle)
    {
        updateByCandle(candle.getHigh(), candle.getLow(), candle.getClose(), candle.getVolume());
    }
}