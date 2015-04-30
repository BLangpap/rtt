#include "TaskContextServerFactory.hpp"
// #include <boost/type_traits/is_base_of.hpp>
// #include <boost/static_assert.hpp>
#include <boost/thread/mutex.hpp>
#include <boost/thread/thread.hpp>
// #include <typeinfo>

using namespace RTT::Communication;


boost::atomic<TaskContextServerFactory*> TaskContextServerFactory::m_Instance(0);
boost::mutex  TCSMapMutex;

/**
 * @brief Default contructor for the task context server factory
 * 
 */
TaskContextServerFactory::TaskContextServerFactory() {}

/**
 * @brief Default destructor for the task context server factory.
 * 
 */
TaskContextServerFactory::~TaskContextServerFactory() {}

/**
 * @brief This methods adds a taskcontext server generator to the list of known generators. If
 * a generator is already listed, the new one will be regarded and needs to be deleted first.
 * 
 * @param NameID The name with which the generator shall be listed
 * @param pTCSGenerator A pointer to the generator
 * @return bool The result of the add-operation
 */
bool TaskContextServerFactory::RegisterTaskContextServerGenerator(std::string NameID, ITaskContextServerGenerator::shared_ptr pTCSGenerator)
{
  bool IsRegistered = false;
  
  // Check whether the passed TCS generator is already listed
  if (m_RegisteredTCSGenerators.find(NameID) == m_RegisteredTCSGenerators.end())
  {
    // Ensure exclusive write access
    boost::unique_lock<boost::mutex> scoped_lock(TCSMapMutex);
    
    // Register the taskcontext server generator
    m_RegisteredTCSGenerators.insert(std::pair<std::string, ITaskContextServerGenerator::shared_ptr>(NameID, pTCSGenerator));
    
    // State the success
    IsRegistered = true;
  }
  
  // Return the result
  return IsRegistered;
}

/**
 * @brief This methods deletes a registered taskcontext server generator
 * 
 * @param NameID The name with which the generator is registerd
 * @return bool The result of the delete operation
 */
bool TaskContextServerFactory::DeleteTaskContextServerGenerator(std::string NameID)
{
  bool IsDeleted = false;
  
  // Check whether the passed TCS generator is already listed
  if (m_RegisteredTCSGenerators.find(NameID) != m_RegisteredTCSGenerators.end())
  {
    // Ensure exclusive write access
    boost::unique_lock<boost::mutex> scoped_lock(TCSMapMutex);
    
    // Delete the registered the taskcontext server generator
    m_RegisteredTCSGenerators.erase(NameID);
    
    // State the success
    IsDeleted = false;
  }
  
  // Return the result
  return IsDeleted;
}


/**
 * @brief Creates a taskcontext server object based upon the desired implementation option.
 * 
 * @param NameID The string/name identifier for the implementation option.
 * @param pTaskContext the task context the taskcontext server shall be attached to.
 * @return RTT::Communication::ITaskContextServer::shared_ptr
 */
ITaskContextServer::shared_ptr TaskContextServerFactory::createTaskContextServer(std::string NameID, TaskContext* pTaskContext)
{
  ITaskContextServer::shared_ptr pTaskContextServer;

  // Check whether the passed TCS generator is already listed
  if (m_RegisteredTCSGenerators.find(NameID) != m_RegisteredTCSGenerators.end())
  {
    // Get the task context server generator and create a new taskcontext server instance
    pTaskContextServer = m_RegisteredTCSGenerators[NameID]->getNewInstance();
    
    // Attach the task context to the server
    pTaskContextServer->AttachTo(pTaskContext);   
  }
  
  return pTaskContextServer;
}