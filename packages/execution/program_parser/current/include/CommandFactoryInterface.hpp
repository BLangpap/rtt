#ifndef COMMANDFACTORYINTERFACE_HPP
#define COMMANDFACTORYINTERFACE_HPP

#include <string>
#include <vector>
#include <utility>
#include "parser-common.hpp"
#include "FactoryExceptions.hpp"

namespace ORO_Execution
{
    typedef std::pair<CommandInterface*, ConditionInterface*> ComCon;

    /**
     * @brief An interface for creating CommandInterface instances.
     *
     * Basically, this class is something which you can ask "give me
     * an object that will call a method by a certain name ( that you
     * pass as a string ), with these arguments ( that you pass in one
     * of two ways, see below )".  There is a generic implementation
     * of this in TemplateCommandFactory.hpp, you are encouraged to
     * use that one, as this interface has some rather difficult
     * requirements..
     *
     * Some of these methods throw exceptions that you can find in
     * FactoryExceptions.hpp
     */
    class CommandFactoryInterface
    {

        public:
            virtual ~CommandFactoryInterface();

            /**
             * Return whether the command com is available..
             * throws nothing.
             */
            virtual bool hasCommand(const std::string& com) const = 0;

            /**
             * Return a list of all available commands..
             * throws nothing.
             */
            virtual std::vector<std::string> commandNames() const = 0;

            /**
             * We need to be able to find out what types of arguments
             * a method needs.  This method returns a PropertyBag
             * containing Property's of the types of the arguments..
             * The user can then fill up this PropertyBag, and
             * construct a command with it via the create method
             * below.
             *
             * Note that the Properties in the property bag have been
             * constructed using new, and the caller gains their
             * ownership..  You should explicitly call
             * deleteProperties on the bag after you're done with it..
             * Store the PropertyBag in a PropertyBagOwner if you're
             * affraid you'll forget it..
             *
             * TODO: fix this requirement somehow..
             * throws name_not_found_exception
             */
            virtual PropertyBag
            getArgumentSpec( const std::string& method ) const = 0;

            /**
             * The companion to getArgumentSpec().  It takes a
             * PropertyBag, containing Property's of the same type and
             * in the same order as the ones that getArgumentSpec()
             * returned, and constructs a ComCon with it..
             *
             * this does not delete the properties in bag, as stated
             * above, if you obtained the propertybag from
             * getArgumentSpec, then you're responsible to delete
             * it..
             * throws name_not_found_exception,
             * wrong_number_of_args_exception, and
             * wrong_types_of_args_exception
             */
            virtual ComCon create( const std::string& method,
                                   const PropertyBag& args ) const = 0;

            /**
             * We also support passing DataSources as the arguments.
             * In this case, the command factory should *not* read out
             * the DataSource's, but it should return a Command and a
             * Condition that store the DataSources, and read them out
             * in their execute() and evaluate() methods.  They should
             * of course both keep a reference to the DataSource's
             * that they store.  These are rather complicated
             * requirements, you are encouraged to look at the
             * TemplateCommandFactory or its helper classes to do
             * (some of) the work for you..  throws
             * name_not_found_exception,
             * wrong_number_of_args_exception, and
             * wrong_types_of_args_exception
             */
            virtual ComCon create(
                const std::string& method,
                const std::vector<DataSourceBase*>& args ) const = 0;

             /**
             * Return a std::string identifying the name
             * of this CommandFactory
             */
            //virtual std::string toString() = 0;

    };
};

#endif
