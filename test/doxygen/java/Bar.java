package gehtsoft.pricearchive.client;

import java.util.Date;

/** A bar.

    A bar is complete information about
    both bid and ask price during the
    specified period of time, e.g. one minute, one day.

    For both, bid and ask prices four statistical values
    are collected: open (first), highest, lowest and close (last)
    rates are recorded. The sets of these values are stored
    as candles (see [Candle](@ref Candle))

    ![Image](sample.jpg)

    [Link](http://www.google.com)

 */
public class Bar
{
    private Date mStart;
    private Date mEnd;
    private Candle mBid;
    private Candle mAsk;

    /** Constructor from a tick.

        @param start    The date when the bar starts (inclusive).
        @param end      The date when the bar ends (exclusive).
        @param bid      The bid price of the first tick in the bar.
        @param ask      The ask price of the first tick in the bar.

     */
    public Bar(Date start, Date end, double bid, double ask)
    {
        mStart = start;
        mEnd = end;
        mBid = new Candle(bid, bid, bid, bid, 1);
        mAsk = new Candle(ask, ask, ask, ask, 1);
    }

    /** Constructor from a tick with volume.

        This constructor is used when the price history has
        volume of the deal recorded with the tick.

        @param start        The date when the bar starts (inclusive).
        @param end          The date when the bar ends (exclusive).
        @param bid          The bid price of the first tick in the bar.
        @param ask          The ask price of the first tick in the bar.

     */
    public Bar(Date start, Date end, double bid, double bidVolume, double ask, double askVolume)
    {
        mStart = start;
        mEnd = end;
        mBid = new Candle(bid, bid, bid, bid, bidVolume);
        mAsk = new Candle(ask, ask, ask, ask, askVolume);

    }

    /** Most complex constructor

        Let's check how **markdown** works `here` ~~strike`it`~~


        ```java
        var a = b;
        ```

        List:
        - Item1
        - Item2

        And... table
        First Header  | Second Header
        ------------- | -------------
        Content Cell  | Content Cell
        Content Cell  | Content Cell
     */
    public Bar(Date start, Date end, double bidOpen, double bidHigh, double bidLow, double bidClose, double bidVolume,
                                     double askOpen, double askHigh, double askLow, double askClose, double askVolume)
    {
        mStart = start;
        mEnd = end;
        mBid = new Candle(bidOpen, bidHigh, bidLow, bidClose, bidVolume);
        mAsk = new Candle(askOpen, askHigh, askLow, askClose, askVolume);

    }

    public Date getStart()
    {
        return mStart;
    }

    public Date getEnd()
    {
        return mEnd;
    }

    public boolean contains(Date date)
    {
        return mStart.getTime() <= date.getTime() && date.getTime() < mEnd.getTime();
    }

    /** Returns bid candle.

        The method returns a read-only copy of a Candle object.
     */

    public Candle getBid()
    {
        return mBid;
    }

    public Candle getAsk()
    {
        return mAsk;
    }

    public void updateByTick(double bid, double bidVolume, double ask, double askVolume)
    {
        mBid.updateByTick(bid, bidVolume);
        mAsk.updateByTick(ask, askVolume);
    }

    public void updateUsingTick(Tick tick)
    {
        updateByTick(tick.getBid(), tick.getBidVolume(), tick.getAsk(), tick.getAskVolume());
    }

    public void updateByCandle(Bar bar)
    {
        mBid.updateByCandle(bar.getBid());
        mAsk.updateByCandle(bar.getAsk());
    }

    public void updateByCandle(double bidHigh, double bidLow, double bidClose, double bidVolume,
                               double askHigh, double askLow, double askClose, double askVolume)
    {
        mBid.updateByCandle(bidHigh, bidLow, bidClose, bidVolume);
        mAsk.updateByCandle(askHigh, askLow, askClose, askVolume);
    }
}
