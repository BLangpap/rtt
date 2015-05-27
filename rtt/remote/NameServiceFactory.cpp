#include "NameServiceFactory.hpp"

using namespace RTT::Communication;


boost::atomic<NameServiceFactory*> NameServiceFactory::m_Instance(0);
boost::mutex  NameServiceMapMutex;

/**
 * @brief Default contructor for the task context server factory
 * 
 */
NameServiceFactory::NameServiceFactory() {}

/**
 * @brief Default destructor for the task context server factory.
 * 
 */
NameServiceFactory::~NameServiceFactory() {}

// Registration methods implementation
/**
 * @brief This methods adds a nameservice generator to the list of known generators. If
 * a generator is already listed, the new one will be disregarded and needs to be deleted first.
 * 
 * @param NameID The name with which the generator shall be listed
 * @param pTCSGenerator A pointer to the generator
 * @return bool The result of the add-operation
 */
bool NameServiceFactory::RegisterNameServiceGenerator(std::string NameID, INameServiceGenerator::shared_ptr pNameServiceGenerator)
{
  bool IsRegistered = false;
  
  // Check whether the passed TCS generator is already listed
  if (m_RegisteredNameServiceGenerators.find(NameID) == m_RegisteredNameServiceGenerators.end())
  {
    // Ensure exclusive write access
    boost::unique_lock<boost::mutex> scoped_lock(NameServiceMapMutex);
    
    // Register the taskcontext server generator
    m_RegisteredNameServiceGenerators.insert(std::pair<std::string, INameServiceGenerator::shared_ptr>(NameID, pNameServiceGenerator));
    
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
bool NameServiceFactory::DeleteNameServiceGenerator(std::string NameID)
{
  bool IsDeleted = false;
  
  // Check whether the passed TCS generator is already listed
  if (m_RegisteredNameServiceGenerators.find(NameID) != m_RegisteredNameServiceGenerators.end())
  {
    // Ensure exclusive write access
    boost::unique_lock<boost::mutex> scoped_lock(NameServiceMapMutex);
    
    // Delete the registered the taskcontext server generator
    m_RegisteredNameServiceGenerators.erase(NameID);
    
    // State the success
    IsDeleted = false;
  }
  
  // Return the result
  return IsDeleted;
}

/**
 * @brief Creates a nameservice object based upon the desired implementation option.
 * 
 * @param NameID The string/name identifier for the implementation option.
 * @return RTT::Communication::ITaskContextServer::shared_ptr
 */
INameService::shared_ptr NameServiceFactory::CreateNameService(std::string NameID)
{
  INameService::shared_ptr pNameService;

  // Check whether the passed TCS generator is already listed
  if (m_RegisteredNameServiceGenerators.find(NameID) != m_RegisteredNameServiceGenerators.end())
  {
    // Get the task context server generator and create a new taskcontext server instance
    pNameService = m_RegisteredNameServiceGenerators[NameID]->getNewInstance();
  }
  
  return pNameService;
}