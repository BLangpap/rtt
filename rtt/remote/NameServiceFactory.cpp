#include "NameServiceFactory.hpp"
#include "CorbaNameService.hpp"

using namespace RTT::Communication;


boost::atomic<NameServiceFactory*> NameServiceFactory::m_Instance(0);

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

/**
 * @brief Creates a name service object based upon the desired implementation option.
 * 
 * @param eNameServiceImpl The desired implementation option.
 * @return RTT::Communication::NameServiceType
 */
NameServiceType NameServiceFactory::createNameService(NameServiceImplementation eNameServiceImpl)
{
  NameServiceType pNameService;

  // Return a name service object depending on name service implementation type
  switch (eNameServiceImpl)
  {
  case NSI_CORBA:
    pNameService.reset(new CorbaNameService());
    break;
  default:
    pNameService.reset();
  }

  return pNameService;
}