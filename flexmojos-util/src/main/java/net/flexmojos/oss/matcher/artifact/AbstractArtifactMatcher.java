/**
 * Flexmojos is a set of maven goals to allow maven users to compile, optimize and test Flex SWF, Flex SWC, Air SWF and Air SWC.
 * Copyright (C) 2008-2012  Marvin Froeder <marvin@flexmojos.net>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package net.flexmojos.oss.matcher.artifact;

import org.hamcrest.Description;
import org.hamcrest.Matcher;
import org.hamcrest.TypeSafeMatcher;

abstract class AbstractArtifactMatcher<E>
    extends TypeSafeMatcher<E>
{
    private String element;

    private Matcher<? extends String> elementMatcher;

    public AbstractArtifactMatcher( Matcher<? extends String> elementMatcher, String element )
    {
        this.elementMatcher = elementMatcher;
        this.element = element;
    }

    public void describeTo( Description description )
    {
        description.appendText( "a dependency with " + element + " " ).appendDescriptionOf( elementMatcher );
    }

    protected abstract String getValue( E item );

    @Override
    public boolean matchesSafely( E item )
    {
        return elementMatcher.matches( getValue( item ) );
    }
}