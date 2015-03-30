/***************************************************************************
  tag: Bernd Langpap  Wed Jan 18 14:09:48 CET 2006  INamingService.hpp

                        TaskContextServerCollection.hpp -  description
                           -------------------
    begin                : Mon March 17 2015
    copyright            : (C) 2015 Bernd Langpap
    email                : bernd.langpap@dfki.de

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
#ifndef REMOTE_TASKCONTEXTSERVERCOLLECTION_HPP
#define REMOTE_TASKCONTEXTSERVERCOLLECTION_HPP

#include <vector>
#include "ITaskContextServer.hpp"
//#include <boost/ptr_container/ptr_vector.hpp>

namespace RTT
{namespace Communication
{
    /**
      * @brief This class realizes the ability to build a collection of different task context server.
      * 
      */
    class TaskContextServerCollection
    {
    private:
      typedef std::vector<TaskContextServerType> TaskContextServerCollectionType;
      TaskContextServerCollectionType m_TaskContextServerCollection;
      
      
    public:
      // Typedefs
      typedef TaskContextServerCollectionType::iterator  TaskContextServerIterator; ///< Iterator to go through the different name service elements
      typedef TaskContextServerCollectionType::size_type TaskContextServerCollectionSizeType; ///< Size type of the name service collection
      
      // Ctor / Dtor
      TaskContextServerCollection();
      ~TaskContextServerCollection(); 
      
      // Methods for handling the name service collection
      void add(TaskContextServerType& pTaskContextServer);
      TaskContextServerIterator begin();
      TaskContextServerIterator end();
      TaskContextServerCollectionSizeType getSize();
    };

}
}

#endif // REMOTE_TASKCONTEXTSERVERCOLLECTION_HPP