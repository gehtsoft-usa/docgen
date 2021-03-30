package gehtsoft.pricearchive.client;
import java.util.List;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Date;

public class BarCollection implements Iterable<Bar> 
{
    private List<Bar> mCollection;
    private String mInstrument;
    private Timeframe mTimeframe;
    private int mPrecision;
    private double mPipSize; 
    private boolean mOpenBarWithFirstTick;
    private int mStartHour;
    
    public BarCollection(String instrument, Timeframe timeframe, double pipSize, int precision)
    {
        mCollection = new ArrayList<>();
        mInstrument = instrument;
        mTimeframe = timeframe;
        mPipSize = pipSize;
        mPrecision = precision;
        mOpenBarWithFirstTick = true;
        mStartHour = 0;
    }
    
    public String getInstrument()
    {
        return mInstrument;
    }
    
    public Timeframe getTimeframe()
    {
        return mTimeframe;
    }
    
    public int getPrecision()
    {
        return mPrecision;
    }
    
    public double getPipSize()
    {
        return mPipSize;
    }
    
    public boolean getOpenBarWithFirstTick()
    {
        return mOpenBarWithFirstTick;
    }
    
    public void setOpenBarWithFirstTick(boolean flag)
    {
        mOpenBarWithFirstTick = flag;
    }
    
    public int getStartHour()
    {
        return mStartHour;
    }
    
    public void setStartHour(int value)
    {
        mStartHour = value;
    }
    
    public int size()
    {
        return mCollection.size();
    }
    
    public Bar get(int index)
    {
        return mCollection.get(index);
    }
    
    public void add(Bar bar)
    {
        mCollection.add(bar);
    }
    
    public Iterator<Bar> iterator() 
    {
        return mCollection.iterator();
    }
    
    public void updateByTick(Date start, double bid, double bidVolume, double ask, double askVolume)
    {
        if (mCollection.isEmpty())
        {
            Date barStart;
            Date barEnd;
            barStart = mTimeframe.getStartDate(start, mStartHour);
            barEnd = mTimeframe.getEndDate(barStart);
            mCollection.add(new Bar(barStart, barEnd, bid, bidVolume, ask, askVolume));
        }
        else
        {
            Bar lastBar = mCollection.get(mCollection.size() - 1);
            if (lastBar.contains(start))
                lastBar.updateByTick(bid, bidVolume, ask, askVolume);
            else
            {
                Date barStart;
                Date barEnd;
                barStart = mTimeframe.getStartDate(start, mStartHour);
                barEnd = mTimeframe.getEndDate(barStart);
                if (mOpenBarWithFirstTick)
                {
                    Bar newBar = new Bar(barStart, barEnd, bid, bidVolume, ask, askVolume);
                    mCollection.add(newBar);
                }
                else
                {
                    Bar newBar = new Bar(barStart, barEnd, lastBar.getBid().getClose(), 0, 
                    lastBar.getAsk().getClose(), 0);
                    newBar.updateByTick(bid, bidVolume, ask, askVolume);
                    mCollection.add(newBar);
                }
            }
        }
    }
    
    public void updateByTick(Tick tick)
    {
        updateByTick(tick.getStart(), tick.getBid(), tick.getBidVolume(), tick.getAsk(), tick.getAskVolume());
    }
    
    public void updateByBar(Date start, double bidOpen, double bidHigh, double bidLow, double bidClose, double bidVolume,
                            double askOpen, double askHigh, double askLow, double askClose, double askVolume)
    {
        if (mCollection.isEmpty())
        {
            Date barStart;
            Date barEnd;
            barStart = mTimeframe.getStartDate(start, mStartHour);
            barEnd = mTimeframe.getEndDate(barStart);
            mCollection.add(new Bar(barStart, barEnd, bidOpen, bidHigh, bidLow, bidClose, bidVolume, askOpen, askHigh, askLow, askClose, askVolume));
        }
        else
        {
            Bar lastBar = mCollection.get(mCollection.size() - 1);
            if (lastBar.contains(start))
                lastBar.updateByCandle(bidHigh, bidLow, bidClose, bidVolume, askHigh, askLow, askClose, askVolume);
            else
            {
                Date barStart;
                Date barEnd;
                barStart = mTimeframe.getStartDate(start, mStartHour);
                barEnd = mTimeframe.getEndDate(barStart);
                Bar newBar;
                if (mOpenBarWithFirstTick)
                     newBar = new Bar(barStart, barEnd, bidOpen, bidHigh, bidLow, bidClose, bidVolume, askOpen, askHigh, askLow, askClose, askVolume);
                else
                {
                    double bidOpen1 = lastBar.getBid().getClose();
                    double askOpen1 = lastBar.getAsk().getClose();
                    newBar = new Bar(barStart, barEnd, bidOpen1, Math.max(bidOpen1, bidHigh), Math.min(bidOpen1, bidLow), bidClose, bidVolume, 
                                                       askOpen1, Math.max(askOpen1, askHigh), Math.min(askOpen1, askLow), askClose, askVolume);
                }
                mCollection.add(newBar);
            }
        }
    }

    public void updateByBar(Bar bar)
    {
        Candle bid;
        Candle ask;
        bid = bar.getBid();
        ask = bar.getAsk();
        updateByBar(bar.getStart(), bid.getOpen(), bid.getHigh(), bid.getLow(), bid.getClose(), bid.getVolume(),
                                    ask.getOpen(), ask.getHigh(), ask.getLow(), ask.getClose(), ask.getVolume());
    }
}
