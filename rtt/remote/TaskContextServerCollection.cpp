#include "TaskContextServerCollection.hpp"

using namespace RTT::Communication;

/**
 * @brief Constructor for a task context server collection
 * 
 */
TaskContextServerCollection::TaskContextServerCollection() 
{
}

/**
 * @brief Destructor for a task context server collection
 * 
 */
TaskContextServerCollection::~TaskContextServerCollection() {}

/**
 * @brief Adds a task context server element to the collection.
 * 
 * @param NameService The task context server to add.
 * @return void
 */
void RTT::Communication::TaskContextServerCollection::add(TaskContextServerType& pTaskContextServer)
{
  m_TaskContextServerCollection.push_back(pTaskContextServer);
}

/**
 * @brief Gets the beginning of the collection.
 * 
 * @return TaskContextServerIterator
 */
RTT::Communication::TaskContextServerCollection::TaskContextServerIterator TaskContextServerCollection::begin()
{
  return m_TaskContextServerCollection.begin();
}

/**
 * @brief Gets the end of the collection.
 * 
 * @return TaskContextServerIterator
 */
RTT::Communication::TaskContextServerCollection::TaskContextServerIterator TaskContextServerCollection::end()
{
  return m_TaskContextServerCollection.end();
}

RTT::Communication::TaskContextServerCollection::TaskContextServerCollectionSizeType TaskContextServerCollection::getSize()
{
  return m_TaskContextServerCollection.size();
}


