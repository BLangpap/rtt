/***************************************************************************
  tag: Peter Soetens  Wed Jan 18 14:11:39 CET 2006  BufferLocked.hpp

                        BufferLocked.hpp -  description
                           -------------------
    begin                : Wed January 18 2006
    copyright            : (C) 2006 Peter Soetens
    email                : peter.soetens@mech.kuleuven.be

 ***************************************************************************
 *   This library is free software; you can redistribute it and/or         *
 *   modify it under the terms of the GNU General Public                   *
 *   License as published by the Free Software Foundation;                 *
 *   version 2 of the License.                                             *
 *                                                                         *
 *   As a special exception, you may use this file as part of a free       *
 *   software library without restriction.  Specifically, if other files   *
 *   instantiate templates or use macros or inline functions from this     *
 *   file, or you compile this file and link it with other files to        *
 *   produce an executable, this file does not by itself cause the         *
 *   resulting executable to be covered by the GNU General Public          *
 *   License.  This exception does not however invalidate any other        *
 *   reasons why the executable file might be covered by the GNU General   *
 *   Public License.                                                       *
 *                                                                         *
 *   This library is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *
 *   Lesser General Public License for more details.                       *
 *                                                                         *
 *   You should have received a copy of the GNU General Public             *
 *   License along with this library; if not, write to the Free Software   *
 *   Foundation, Inc., 59 Temple Place,                                    *
 *   Suite 330, Boston, MA  02111-1307  USA                                *
 *                                                                         *
 ***************************************************************************/





#ifndef ORO_CORELIB_BUFFER_LOCKED_HPP
#define ORO_CORELIB_BUFFER_LOCKED_HPP

#include "../os/Mutex.hpp"
#include "../os/MutexLock.hpp"
#include "BufferInterface.hpp"
#include <deque>

namespace RTT
{ namespace base {


    /**
     * Implements a very simple blocking thread-safe buffer, using mutexes (locks).
     *
     * @see BufferLockFree
     * @ingroup PortBuffers
     */
    template<class T>
    class BufferLocked
        :public BufferInterface<T>
    {
    public:

        typedef typename BufferInterface<T>::reference_t reference_t;
        typedef typename BufferInterface<T>::param_t param_t;
        typedef typename BufferInterface<T>::size_type size_type;
        typedef T value_t;

        /**
         * Create a buffer of size \a size, with preallocated data storage.
         * @param size The number of elements this buffer can hold.
         * @param initial_value A data sample with which each preallocated data element is initialized.
         * @param circular Set flag to true to make this buffer circular. If not circular, new values are discarded on full.
         */
        BufferLocked( size_type size, const T& initial_value = T(), bool circular = false )
            : cap(size), buf(), mcircular(circular)
        {
            data_sample(initial_value);
        }

        virtual void data_sample( const T& sample )
        {
            buf.resize(cap, sample);
            buf.resize(0);
            lastSample = sample;
        }

        virtual T data_sample() const
        {
            return lastSample;
        }

        /**
         * Destructor
         */
        ~BufferLocked() {}

        bool Push( param_t item )
        {
            os::MutexLock locker(lock);
            if ( cap == (size_type)buf.size() ) {
                if (!mcircular)
                    return false;
                else
                    buf.pop_front();
            }
            buf.push_back( item );
            return true;
        }

        size_type Push(const std::vector<T>& items)
        {
            os::MutexLock locker(lock);
            typename std::vector<T>::const_iterator itl( items.begin() );
            if (mcircular && (size_type)items.size() >= cap ) {
                // clear out current data and reset iterator to first element we're going to take.
                buf.clear();
                itl = items.begin() + ( items.size() - cap );
            } else if ( mcircular && (size_type)(buf.size() + items.size()) > cap) {
                // drop excess elements from front
                assert( (size_type)items.size() < cap );
                while ( (size_type)(buf.size() + items.size()) > cap )
                    buf.pop_front();
                // itl still points at first element of items.
            }
            while ( ((size_type)buf.size() != cap) && (itl != items.end()) ) {
                buf.push_back( *itl );
                ++itl;
            }
            // this is in any case the number of elements taken from items.
            if (mcircular)
                assert( (size_type)(itl - items.begin() ) == (size_type)items.size() );
            return (itl - items.begin());

        }
        bool Pop( reference_t item )
        {
            os::MutexLock locker(lock);
            if ( buf.empty() ) {
                return false;
            }
            item = buf.front();
            buf.pop_front();
            return true;
        }

        size_type Pop(std::vector<T>& items )
        {
            os::MutexLock locker(lock);
            int quant = 0;
            items.clear();
            while ( !buf.empty() ) {
                items.push_back( buf.front() );
                buf.pop_front();
                ++quant;
            }
            return quant;
        }

	value_t* PopWithoutRelease()
	{
            os::MutexLock locker(lock);
	    if(buf.empty())
		return 0;
	    
	    //note we need to copy the sample, as 
	    //front is not garanteed to be valid after
	    //any other operation on the deque
	    lastSample = buf.front();
	    buf.pop_front();
	    return &lastSample;
	}
	
	void Release(value_t *item)
	{
	    //we do not need to release any memory, but we can check
	    //if the other side messed up
	    assert(item == &lastSample && "Wrong pointer given back to buffer");
	}

        size_type capacity() const {
            os::MutexLock locker(lock);
            return cap;
        }

        size_type size() const {
            os::MutexLock locker(lock);
            return buf.size();
        }

        void clear() {
            os::MutexLock locker(lock);
            buf.clear();
        }

        bool empty() const {
            os::MutexLock locker(lock);
            return buf.empty();
        }

        bool full() const {
            os::MutexLock locker(lock);
            return (size_type)buf.size() ==  cap;
        }
    private:
        size_type cap;
        std::deque<T> buf;
        value_t lastSample;
        mutable os::Mutex lock;
        const bool mcircular;
    };
}}

#endif // BUFFERSIMPLE_HPP
